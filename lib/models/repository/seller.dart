/// Facade over the SQLite order tables.
///
/// The former God Object (~880 lignes) has been split into three
/// single-responsibility units (Laws 1.1 / 1.2 / 1.3 of `.cursorrules`):
///
/// - `SellerRepository` — CRUD & reset-id state
/// - `SellerAnalyticsQueries` — read-only aggregation queries
/// - `metric_enums.dart` — DTOs, Enums, [Period], [SellerTables]
///
/// This facade preserves the historical `Seller.instance` public surface so
/// the 30+ import sites across the app do not have to change.
library;

import 'package:flutter/foundation.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller/analytics_queries.dart';
import 'package:possystem/models/repository/seller/metric_enums.dart';
import 'package:possystem/models/repository/seller/seller_repository.dart';
import 'package:possystem/models/shift/shift_report.dart';

export 'package:possystem/models/repository/seller/metric_enums.dart';
export 'package:possystem/models/shift/shift_report.dart';

/// Thin facade exposing the historical [Seller] API.
///
/// It forwards CRUD to [SellerRepository] and analytics to
/// [SellerAnalyticsQueries]. It also re-broadcasts the repository's change
/// notifications so widgets that still listen to `Seller.instance` (order
/// history, analytics cards, cart wipe) keep working unchanged.
class Seller extends ChangeNotifier {
  /// Preserved for backwards compatibility with call sites that reference
  /// `Seller.orderTable`, `Seller.productTable`, etc.
  static const String orderTable = SellerTables.order;
  static const String productTable = SellerTables.product;
  static const String ingredientTable = SellerTables.ingredient;
  static const String attributeTable = SellerTables.attribute;

  /// Singleton instance.
  static Seller instance = Seller._();

  final SellerRepository _repository;
  final SellerAnalyticsQueries _analytics;

  Seller._()
    : _repository = SellerRepository.instance,
      _analytics = SellerAnalyticsQueries.instance {
    _repository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _repository.removeListener(notifyListeners);
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Reset-id state (delegated to SellerRepository)
  // -------------------------------------------------------------------------

  int get idOffset => _repository.idOffset;

  DateTime? get resetIdNext => _repository.resetIdNext;

  @visibleForTesting
  set resetIdNext(DateTime? value) => _repository.resetIdNext = value;

  Future<void> updateResetIdPeriod(Period period) =>
      _repository.updateResetIdPeriod(period);

  Future<void> resetId() => _repository.resetId();

  Future<void> checkResetIdByPeriod() => _repository.checkResetIdByPeriod();

  // -------------------------------------------------------------------------
  // CRUD (delegated to SellerRepository)
  // -------------------------------------------------------------------------

  Future<void> push(OrderObject order) => _repository.push(order);

  Future<void> delete(int id) => _repository.delete(id);

  Future<void> clear(DateTime notAfter) => _repository.clear(notAfter);

  // -------------------------------------------------------------------------
  // Analytics (delegated to SellerAnalyticsQueries)
  // -------------------------------------------------------------------------

  Future<OrderMetrics> getMetrics(
    DateTime start,
    DateTime end, {
    bool countingAll = false,
  }) => _analytics.getMetrics(start, end, countingAll: countingAll);

  Future<List<OrderSummary>> getMetricsInPeriod(
    DateTime start,
    DateTime end, {
    List<OrderMetricType> types = const [OrderMetricType.count],
    MetricsIntervalType interval = MetricsIntervalType.day,
    bool ignoreEmpty = true,
    String orderDirection = 'asc',
    int? limit,
  }) => _analytics.getMetricsInPeriod(
    start,
    end,
    types: types,
    interval: interval,
    ignoreEmpty: ignoreEmpty,
    orderDirection: orderDirection,
    limit: limit,
  );

  Future<List<OrderSummary>> getItemMetricsInPeriod(
    DateTime start,
    DateTime end, {
    required OrderMetricType type,
    required OrderMetricTarget target,
    MetricsIntervalType interval = MetricsIntervalType.day,
    List<String> selection = const [],
    bool ignoreEmpty = true,
  }) => _analytics.getItemMetricsInPeriod(
    start,
    end,
    type: type,
    target: target,
    interval: interval,
    selection: selection,
    ignoreEmpty: ignoreEmpty,
  );

  Future<List<OrderMetricPerItem>> getMetricsByItems(
    DateTime start,
    DateTime end, {
    required OrderMetricType type,
    required OrderMetricTarget target,
    List<String> selection = const [],
    bool ignoreEmpty = false,
  }) => _analytics.getMetricsByItems(
    start,
    end,
    type: type,
    target: target,
    selection: selection,
    ignoreEmpty: ignoreEmpty,
  );

  Future<List<OrderObject>> getOrders(
    DateTime start,
    DateTime end, {
    int offset = 0,
    int limit = 10,
  }) => _analytics.getOrders(start, end, offset: offset, limit: limit);

  Future<List<OrderObject>> getDetailedOrders(DateTime start, DateTime end) =>
      _analytics.getDetailedOrders(start, end);

  Future<OrderObject?> getOrder(int id) => _analytics.getOrder(id);

  Future<ShiftReport> getShiftReport(String shiftId) =>
      _analytics.getShiftReport(shiftId);
}
