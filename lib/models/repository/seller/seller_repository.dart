import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller/metric_enums.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/services/database.dart';

/// Owns every SQLite write on the four order tables and the reset-id state.
///
/// Kept intentionally small (single-responsibility per Law 1.1 / 1.3): no
/// aggregation queries here — those live in `SellerAnalyticsQueries`.
///
/// Extends [ChangeNotifier] because a handful of legacy widgets (order list,
/// history, cart wipe) still `AnimatedBuilder`-listen to the [Seller] facade
/// after every `push` / `delete` / `clear`.
class SellerRepository extends ChangeNotifier {
  /// Singleton instance.
  static SellerRepository instance = SellerRepository._();

  SellerRepository._();

  int? _idOffset;
  DateTime? _resetIdNext;

  int get idOffset =>
      _idOffset ??= Cache.instance.get<int>('order.idOffset') ?? 0;

  DateTime? get resetIdNext =>
      _resetIdNext ??= Period.fromCache().nextDateFromCache();

  @visibleForTesting
  set resetIdNext(DateTime? value) => _resetIdNext = value;

  Future<void> updateResetIdPeriod(Period period) async {
    _resetIdNext = await period.saveToCache();
  }

  Future<void> resetId() async {
    final response = await Database.instance.query(
      'sqlite_sequence',
      columns: ['seq'],
      where: 'name = ?',
      whereArgs: [SellerTables.order],
    );
    final offset = _idOffset =
        (response.firstOrNull?['seq'] as num?)?.toInt() ?? 0;
    await Cache.instance.set('order.idOffset', offset);
  }

  Future<void> checkResetIdByPeriod() async {
    if (resetIdNext != null) {
      final today = Period.today();
      if (resetIdNext == today || resetIdNext!.isBefore(today)) {
        // If today is the next reset date, we need to reset the ID.
        _resetIdNext = Period.fromCache().nextDate(resetIdNext!, today);

        await Period.cacheNext(resetIdNext!);
        await resetId();
      }
    }
  }

  /// Push order to the DB.
  ///
  /// All inserts happen inside a single transaction and are grouped in three
  /// batches (products, ingredients, attributes) instead of one round-trip per
  /// product. This removes the N+1 pattern that used to make checkout latency
  /// grow linearly with the cart size (Law 2.2 of .cursorrules).
  Future<void> push(OrderObject order) async {
    await checkResetIdByPeriod();

    await Database.instance.transaction((txn) async {
      final orderMap = order.toMap();
      final createdAt = orderMap['createdAt'];

      final id = await txn.insert(SellerTables.order, orderMap);
      await txn.update(
        SellerTables.order,
        {'periodSeq': id - idOffset},
        where: 'id = ?',
        whereArgs: [id],
      );

      // Batch #1 - products. We must NOT pass `noResult: true` here because
      // the generated rowids are needed to link the ingredients back to
      // their product line.
      List<Object?> productIds = const [];
      if (order.products.isNotEmpty) {
        final productBatch = txn.batch();
        for (final product in order.products) {
          final map = product.toMap();
          map['orderId'] = id;
          map['createdAt'] = createdAt;
          productBatch.insert(SellerTables.product, map);
        }
        productIds = await productBatch.commit();
      }

      // Batch #2 - ingredients for every product, linked via the ids we just
      // collected. `productIds` is in the same order as `order.products`
      // because sqflite preserves batch ordering.
      var hasIngredients = false;
      final ingredientBatch = txn.batch();
      for (var i = 0; i < order.products.length; i++) {
        final product = order.products[i];
        if (product.ingredients.isEmpty) continue;
        final pid = productIds[i] as int;
        for (final ingredient in product.ingredients) {
          final map = ingredient.toMap();
          map['orderId'] = id;
          map['orderProductId'] = pid;
          map['createdAt'] = createdAt;
          ingredientBatch.insert(SellerTables.ingredient, map);
          hasIngredients = true;
        }
      }
      if (hasIngredients) {
        await ingredientBatch.commit(noResult: true);
      }

      // Batch #3 - order-level attributes (dine in / take away / …).
      if (order.attributes.isNotEmpty) {
        final attributeBatch = txn.batch();
        for (final attr in order.attributes) {
          final map = attr.toMap();
          map['orderId'] = id;
          map['createdAt'] = createdAt;
          attributeBatch.insert(SellerTables.attribute, map);
        }
        await attributeBatch.commit(noResult: true);
      }

      return id;
    });

    notifyListeners();
  }

  /// Delete order and all the other artifacts.
  Future<void> delete(int id) async {
    await Database.instance.transaction((txn) async {
      await txn.delete(SellerTables.order, where: 'id = ?', whereArgs: [id]);

      final w = 'orderId = ?';
      await txn.delete(SellerTables.product, where: w, whereArgs: [id]);
      await txn.delete(SellerTables.ingredient, where: w, whereArgs: [id]);
      await txn.delete(SellerTables.attribute, where: w, whereArgs: [id]);
    });

    notifyListeners();
  }

  Future<void> clear(DateTime notAfter) async {
    await Database.instance.transaction((txn) async {
      final begin = Util.toUTC(now: notAfter);
      final w = 'createdAt < ?';

      await txn.delete(SellerTables.order, where: w, whereArgs: [begin]);
      await txn.delete(SellerTables.product, where: w, whereArgs: [begin]);
      await txn.delete(SellerTables.ingredient, where: w, whereArgs: [begin]);
      await txn.delete(SellerTables.attribute, where: w, whereArgs: [begin]);
    });

    notifyListeners();
  }
}
