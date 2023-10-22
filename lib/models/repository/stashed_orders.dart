import 'package:flutter/foundation.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';

/// Help I/O from stashed order DB.
class StashedOrders extends ChangeNotifier {
  static const table = 'order_stash';

  static final instance = StashedOrders();

  /// Stash the order to recover later.
  ///
  /// It will also save the order attributes.
  Future<void> stash(OrderObject order) async {
    await Database.instance.push(table, order.toStashMap());
    notifyListeners();
  }

  /// Get the stashed orders.
  Future<List<OrderObject>> getItems({
    int offset = 0,
    int? limit = 10,
  }) async {
    final rows = await Database.instance.query(
      table,
      orderBy: 'createdAt desc',
      limit: limit,
      offset: offset,
    );

    return rows.map((e) => OrderObject.fromStashMap(e)).toList();
  }

  /// Get the stashed orders.
  Future<StashedOrderMetrics> getMetrics() async {
    final rows = await Database.instance.query(
      table,
      columns: ['COUNT(*) count'],
    );

    return StashedOrderMetrics.fromMap(rows.isEmpty ? {} : rows[0]);
  }

  /// Get specific stashed order by id and delete that entry.
  Future<void> delete(int id) async {
    await Database.instance.delete(table, id);
    notifyListeners();
  }
}

/// Metrics from [StashedOrders.getMetrics]
class StashedOrderMetrics {
  /// Total count of stashed orders.
  final int count;

  const StashedOrderMetrics._({
    required this.count,
  });

  /// Directly from DB data.
  factory StashedOrderMetrics.fromMap(Map<String, Object?> map) {
    return StashedOrderMetrics._(
      count: map['count'] as int? ?? 0,
    );
  }
}
