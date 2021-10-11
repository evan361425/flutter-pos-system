import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';

class Seller extends ChangeNotifier {
  static const STASH_TABLE = 'order_stash';

  static const ORDER_TABLE = 'order';

  static const JOIN_COMBINATION = JoinQuery(
    joinType: 'LEFT',
    hostTable: ORDER_TABLE,
    guestTable: 'customer_setting_combinations',
    hostKey: 'customerSettingCombinationId',
    guestKey: 'id',
  );

  static late Seller instance;

  Seller() {
    instance = this;
  }

  Future<OrderObject?> drop() async {
    final row = await Database.instance.getLast(
      STASH_TABLE,
      join: JOIN_COMBINATION,
      columns: const [
        'id',
        'encodedProducts',
        'combination',
        'createdAt',
      ],
    );
    if (row == null) return null;

    final object = OrderObject.fromMap(row);

    await Database.instance.delete(STASH_TABLE, object.id);

    return object;
  }

  Future<Map<DateTime, int>> getCountBetween(
    DateTime start,
    DateTime end, {
    range = '%d',
  }) async {
    final rows = await Database.instance.query(
      ORDER_TABLE,
      columns: ['COUNT(*) count', 'createdAt'],
      where: 'createdAt BETWEEN ? AND ?',
      groupBy: "STRFTIME('$range', createdAt,'unixepoch')",
      whereArgs: [
        Util.toUTC(now: start),
        Util.toUTC(now: end),
      ],
    );

    return {
      for (final row in rows)
        Util.fromUTC(row['createdAt'] as int): row['count'] as int
    };
  }

  Future<Map<String, num>> getMetricBetween([
    DateTime? start,
    DateTime? end,
  ]) async {
    final begin = start == null ? Util.toUTC(hour: 0) : Util.toUTC(now: start);
    final finish = end == null ? 9999999999 : Util.toUTC(now: end);

    final result = await Database.instance.query(ORDER_TABLE,
        columns: ['COUNT(*) count', 'SUM(totalPrice) totalPrice'],
        where: 'createdAt BETWEEN ? AND ?',
        whereArgs: [begin, finish]);

    final row = result.isEmpty ? <String, Object?>{} : result[0];

    return {
      'totalPrice': row['totalPrice'] as num? ?? 0,
      'count': row['count'] as num? ?? 0,
    };
  }

  Future<List<OrderObject>> getOrderBetween(
    DateTime start,
    DateTime end, [
    int offset = 0,
  ]) async {
    final rows = await Database.instance.query(
      ORDER_TABLE,
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [
        Util.toUTC(now: start),
        Util.toUTC(now: end),
      ],
      join: JOIN_COMBINATION,
      orderBy: 'createdAt desc',
      limit: 10,
      offset: offset,
    );

    return rows.map((row) => OrderObject.fromMap(row)).toList();
  }

  Future<num> getStashCount() async {
    final count = await Database.instance.count(STASH_TABLE);

    return count ?? 0;
  }

  Future<OrderObject?> getTodayLast() async {
    final row = await Database.instance.getLast(
      ORDER_TABLE,
      columns: const [
        'totalCount',
        'totalPrice',
        'id',
        'encodedProducts',
        'createdAt',
        'combination',
      ],
      where: 'createdAt >= ?',
      whereArgs: [Util.toUTC(hour: 0)],
      join: JOIN_COMBINATION,
    );

    return row == null ? null : OrderObject.fromMap(row);
  }

  Future<int> push(OrderObject order) async {
    final id = await Database.instance.push(ORDER_TABLE, order.toMap());
    notifyListeners();

    return id;
  }

  /// Save the order in to DB
  ///
  /// It will not save customer setting.
  Future<int> stash(OrderObject order) {
    final data = order.toMap();

    return Database.instance.push(STASH_TABLE, {
      'createdAt': data['createdAt'],
      'customerSettingCombinationId': data['customerSettingCombinationId'],
      'encodedProducts': data['encodedProducts'],
    });
  }

  Future<void> update(OrderObject order) async {
    await Database.instance.update(ORDER_TABLE, order.id, order.toMap());
    notifyListeners();
  }
}
