import 'package:possystem/helpers/db_transferer.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';

class Seller {
  static Seller instance = Seller();

  Future<OrderObject?> drop() async {
    final row = await Database.instance.getLast(
      Tables.order_stash,
      columns: ['id', 'encodedProducts', 'createdAt'],
    );
    if (row == null) return null;

    final object = OrderObject.fromMap(row);

    await Database.instance.delete(Tables.order_stash, object.id);

    return object;
  }

  Future<int> genCustomerSettingCombinationId(Map<int, int> data) {
    return Database.instance.push(Tables.customer_setting_combinations, {
      'combination': DBTransferer.toCombination(data),
    });
  }

  Future<Map<DateTime, int>> getCountBetween(
    DateTime start,
    DateTime end, {
    range = '%d',
  }) async {
    final rows = await Database.instance.rawQuery(
      Tables.order,
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

  Future<int?> getCustomerSettingCombinationId(Map<int, int> data) async {
    final result = await Database.instance.query(
      Tables.customer_setting_combinations,
      columns: ['id'],
      where: 'combination = ?',
      whereArgs: [DBTransferer.toCombination(data)],
      limit: 1,
    );

    return result.isEmpty ? null : (result.first['id'] as int);
  }

  Future<Map<String, num>> getMetricBetween([
    DateTime? start,
    DateTime? end,
  ]) async {
    final begin = start == null ? Util.toUTC(hour: 0) : Util.toUTC(now: start);
    final finish = end == null ? 9999999999 : Util.toUTC(now: end);

    final result = await Database.instance.query(Tables.order,
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
      Tables.order,
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [
        Util.toUTC(now: start),
        Util.toUTC(now: end),
      ],
      orderBy: 'createdAt desc',
      limit: 10,
      offset: offset,
    );

    return rows.map((row) => OrderObject.fromMap(row)).toList();
  }

  Future<num> getStashCount() async {
    final count = await Database.instance.count(Tables.order_stash);

    return count ?? 0;
  }

  Future<OrderObject?> pop() async {
    final row = await Database.instance.getLast(Tables.order,
        columns: ['id', 'encodedProducts', 'createdAt'],
        where: 'createdAt >= ?',
        whereArgs: [Util.toUTC(hour: 0)]);
    if (row == null) return null;

    return OrderObject.fromMap(row);
  }

  Future<void> push(OrderObject order) {
    return Database.instance.push(Tables.order, order.toMap());
  }

  Future<void> stash(OrderObject order) {
    final data = order.toMap();

    return Database.instance.push(Tables.order_stash, {
      'createdAt': data['createdAt'],
      'encodedProducts': data['encodedProducts'],
    });
  }

  Future<void> update(OrderObject order) {
    return Database.instance.update(
      Tables.order,
      order.id,
      order.toMap(),
    );
  }
}
