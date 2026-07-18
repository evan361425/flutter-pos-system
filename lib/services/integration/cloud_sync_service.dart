import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/integration/cloud_config.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cloud_mapping_repository.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/stashed_orders.dart';
import 'package:possystem/services/api/api_client.dart';
import 'package:possystem/services/api/api_exception.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/services/sync/sync_service.dart';

/// Facade for e-commerce / cloud inventory + inbound order integration.
///
/// Outbound stock updates go through [SyncService] outbox (never block checkout).
/// Inbound polling is a background [Timer.periodic] that must never crash the UI.
class CloudSyncService {
  CloudSyncService._();

  static final CloudSyncService instance = CloudSyncService._();

  static const inventoryEndpoint = 'ecommerce/inventory/update';
  static const pendingOrdersPath = 'ecommerce/orders/pending';
  static const Duration _pollInterval = Duration(minutes: 2);
  static const String _processedIdsCacheKey = 'cloud.processedInboundIds';
  static const int _maxProcessedIds = 200;
  static const String webOrderNotePrefix = 'Web Order';

  Timer? _inboundTimer;
  bool _isPolling = false;

  /// Swap HTTP client in tests (delegates to [ApiClient]).
  void setHttpClient(http.Client client) {
    ApiClient.instance.setHttpClient(client);
  }

  /// Decrement remote stock for a local sale via the outbox (Law 3.1 / 3.2).
  ///
  /// Never throws to the caller — failures are logged and swallowed so checkout
  /// stays offline-first.
  Future<void> decrementOnlineStock(OrderObject order) async {
    try {
      final config = CloudConfig.load();
      if (!config.isConfigured) return;

      final localIds = order.products.map((p) => p.productId);
      final mappings = await CloudMappingRepository.instance.getByLocalIds(
        localIds,
      );
      if (mappings.isEmpty) {
        Log.ger('cloud_stock_skip_unmapped', {
          'products': order.products.length,
        });
        return;
      }

      final updates = <Map<String, Object?>>[];
      for (final product in order.products) {
        final mapping = mappings[product.productId];
        if (mapping == null) continue;
        updates.add({
          'external_product_id': mapping.externalProductId,
          if (mapping.externalVariantId != null)
            'external_variant_id': mapping.externalVariantId,
          'quantity_delta': -product.count,
          'local_product_id': product.productId,
        });
      }

      if (updates.isEmpty) return;

      final payload = {
        'store_url': config.storeUrl,
        'source': 'pos_checkout',
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updates': updates,
      };

      await SyncService.instance.enqueue(payload, inventoryEndpoint);
      Log.ger('cloud_stock_enqueued', {'count': updates.length});
    } catch (e, stack) {
      Log.err(e, 'cloud_stock_decrement_failed', stack);
    }
  }

  /// Start background polling of pending web orders (Law 3.5 / 4.4).
  void startPollingInboundOrders() {
    _inboundTimer?.cancel();
    final config = CloudConfig.load();
    if (!config.isConfigured) {
      Log.ger('cloud_poll_skipped', {'reason': 'inactive_or_unconfigured'});
      return;
    }

    _inboundTimer = Timer.periodic(_pollInterval, (_) {
      unawaited(_pollInboundOrdersSafe());
    });
    unawaited(_pollInboundOrdersSafe());
    Log.ger('cloud_poll_started', {'interval_min': _pollInterval.inMinutes});
  }

  /// Stop the inbound poller (idempotent).
  void stopPollingInboundOrders() {
    _inboundTimer?.cancel();
    _inboundTimer = null;
    Log.ger('cloud_poll_stopped', {});
  }

  /// Apply config changes: start or stop polling based on [CloudConfig.isActive].
  void applyConfig(CloudConfig config) {
    if (config.isConfigured) {
      startPollingInboundOrders();
    } else {
      stopPollingInboundOrders();
    }
  }

  Future<void> _pollInboundOrdersSafe() async {
    if (_isPolling) return;
    _isPolling = true;
    try {
      await _pollInboundOrders();
    } catch (e, stack) {
      Log.err(e, 'cloud_poll_unhandled', stack);
    } finally {
      _isPolling = false;
    }
  }

  Future<void> _pollInboundOrders() async {
    final config = CloudConfig.load();
    if (!config.isConfigured) return;

    List<Map<String, dynamic>> remoteOrders;
    try {
      remoteOrders = await _fetchPendingOrders();
    } on ApiException catch (e, stack) {
      Log.err(e, 'cloud_poll_http_failed', stack);
      return;
    } catch (e, stack) {
      Log.err(e, 'cloud_poll_http_failed', stack);
      return;
    }

    final processed = _loadProcessedIds();
    for (final raw in remoteOrders) {
      try {
        final externalId = raw['id']?.toString() ?? '';
        if (externalId.isEmpty || processed.contains(externalId)) continue;

        final status = raw['status']?.toString().toLowerCase();
        if (status != null && status != 'pending') continue;

        final order = await _translateRemoteOrder(raw, externalId);
        if (order == null || order.products.isEmpty) {
          Log.ger('cloud_inbound_skip', {
            'id': externalId,
            'reason': 'unmapped',
          });
          continue;
        }

        await StashedOrders.instance.stash(order);
        processed.add(externalId);
        Log.ger('cloud_inbound_stashed', {
          'id': externalId,
          'products': order.products.length,
        });
      } catch (e, stack) {
        Log.err(e, 'cloud_inbound_order_failed', stack);
      }
    }
    await _saveProcessedIds(processed);
  }

  Future<List<Map<String, dynamic>>> _fetchPendingOrders() async {
    final response = await ApiClient.instance.get(pendingOrdersPath);
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (decoded is Map && decoded['orders'] is List) {
      return (decoded['orders'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<OrderObject?> _translateRemoteOrder(
    Map<String, dynamic> raw,
    String externalId,
  ) async {
    final items = raw['items'] ?? raw['line_items'] ?? const [];
    if (items is! List || items.isEmpty) return null;

    final allMappings = await CloudMappingRepository.instance.getAll();
    final byExternal = <String, ProductMapping>{};
    for (final m in allMappings) {
      final key = _externalKey(m.externalProductId, m.externalVariantId);
      byExternal[key] = m;
    }

    final products = <OrderProductObject>[];
    num productsPrice = 0;
    var productsCount = 0;

    for (final item in items) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final externalProductId =
          map['product_id']?.toString() ??
          map['external_product_id']?.toString() ??
          '';
      final externalVariantId =
          map['variant_id']?.toString() ??
          map['external_variant_id']?.toString();
      final qty = (map['quantity'] as num?)?.toInt() ?? 1;
      if (externalProductId.isEmpty || qty <= 0) continue;

      final mapping =
          byExternal[_externalKey(externalProductId, externalVariantId)];
      if (mapping == null) continue;

      final menuProduct = Menu.instance.getProduct(mapping.localProductId);
      final name = menuProduct?.name ?? map['name']?.toString() ?? 'Web item';
      final catalogName = menuProduct?.catalog.name ?? 'Web';
      final unitPrice = (map['price'] as num?) ?? menuProduct?.price ?? 0;
      final unitCost = menuProduct?.cost ?? 0;
      final taxRate = menuProduct?.taxRate ?? 0;

      products.add(
        OrderProductObject(
          productId: mapping.localProductId,
          productName: name,
          catalogName: catalogName,
          count: qty,
          singleCost: unitCost,
          singlePrice: unitPrice,
          originalPrice: unitPrice,
          taxRate: taxRate,
        ),
      );
      productsCount += qty;
      productsPrice += unitPrice * qty;
    }

    if (products.isEmpty) return null;

    final noteFromRemote = raw['note']?.toString() ?? '';
    final note = noteFromRemote.isEmpty
        ? '$webOrderNotePrefix #$externalId'
        : '$webOrderNotePrefix #$externalId — $noteFromRemote';

    return OrderObject(
      note: note,
      price: productsPrice,
      productsPrice: productsPrice,
      productsCount: productsCount,
      cost: products.fold<num>(0, (s, p) => s + p.totalCost),
      products: products,
      createdAt: DateTime.now(),
    );
  }

  static String _externalKey(String productId, String? variantId) {
    final v = (variantId == null || variantId.isEmpty) ? '' : variantId;
    return '$productId::$v';
  }

  Set<String> _loadProcessedIds() {
    try {
      final raw = Cache.instance.get<String>(_processedIdsCacheKey);
      if (raw == null || raw.isEmpty) return <String>{};
      final list = jsonDecode(raw);
      if (list is! List) return <String>{};
      return list.map((e) => e.toString()).toSet();
    } catch (e, stack) {
      Log.err(e, 'cloud_processed_ids_load', stack);
      return <String>{};
    }
  }

  Future<void> _saveProcessedIds(Set<String> ids) async {
    try {
      final trimmed = ids.length > _maxProcessedIds
          ? ids.skip(ids.length - _maxProcessedIds).toList()
          : ids.toList();
      await Cache.instance.set<String>(
        _processedIdsCacheKey,
        jsonEncode(trimmed),
      );
    } catch (e, stack) {
      Log.err(e, 'cloud_processed_ids_save', stack);
    }
  }

  /// Release timer resources (Law 4.4). HTTP client stays on [ApiClient].
  void dispose() {
    stopPollingInboundOrders();
  }
}
