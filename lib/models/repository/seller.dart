import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';

/// Help I/O from order DB.
class Seller extends ChangeNotifier {
  static const stashTable = 'order_stash';

  static const orderTable = 'order_records';

  static const productTable = 'order_products';

  static const ingredientTable = 'order_ingredients';

  static const attributeTable = 'order_attributes';

  static late Seller instance;

  Seller() {
    instance = this;
  }

  Future<Map<DateTime, int>> getCountPerDay(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await Database.instance.query(
      orderTable,
      columns: ['createdAt'],
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [
        Util.toUTC(now: start),
        Util.toUTC(now: end),
      ],
    );

    final result = <DateTime, int>{};
    for (final row in rows) {
      final c = Util.fromUTC(row['createdAt'] as int);
      final d = DateTime(c.year, c.month, c.day);
      result[d] = (result[d] ?? 0) + 1;
    }

    return result;
  }

  Future<OrderMetrics> getMetrics(
    DateTime start,
    DateTime end, {
    bool countingAll = false,
  }) async {
    final begin = Util.toUTC(now: start);
    final finish = Util.toUTC(now: end);
    final queries = [
      Database.instance.query(
        orderTable,
        columns: [
          'COUNT(*) count',
          'SUM(price) price',
          'SUM(cost) cost',
          'SUM(revenue) revenue',
        ],
        where: 'createdAt BETWEEN ? AND ?',
        whereArgs: [begin, finish],
      ),
    ];

    if (countingAll) {
      queries.addAll([
        Database.instance.query(
          productTable,
          // so far so good, add new if we need it
          columns: ['COUNT(*) count'],
          where: 'createdAt BETWEEN ? AND ?',
          whereArgs: [begin, finish],
        ),
        Database.instance.query(
          ingredientTable,
          // so far so good, add new if we need it
          columns: ['COUNT(*) count'],
          where: 'createdAt BETWEEN ? AND ?',
          whereArgs: [begin, finish],
        ),
        Database.instance.query(
          attributeTable,
          // so far so good, add new if we need it
          columns: ['COUNT(*) count'],
          where: 'createdAt BETWEEN ? AND ?',
          whereArgs: [begin, finish],
        ),
      ]);
    }

    final result = await Future.wait(queries);

    try {
      final order = result[0][0];
      int? productCount;
      int? ingredientCount;
      int? attrCount;
      if (countingAll) {
        productCount = result[1][0]['count'] as int;
        ingredientCount = result[2][0]['count'] as int;
        attrCount = result[3][0]['count'] as int;
      }

      return OrderMetrics.fromMap(
        order,
        productCount: productCount,
        ingredientCount: ingredientCount,
        attrCount: attrCount,
      );
    } catch (e) {
      return OrderMetrics.fromMap(const {});
    }
  }

  /// Get orders and its products info from time range.
  Future<List<OrderObject>> getOrders(
    DateTime start,
    DateTime end, {
    int offset = 0,
    int? limit = 10,
  }) async {
    final rows = await Database.instance.query(
      orderTable,
      columns: [
        '$orderTable.*',
        'GROUP_CONCAT($productTable.productName, ${Database.queryDelimiter}) AS pn',
        'GROUP_CONCAT($productTable.count, ${Database.queryDelimiter}) AS pc',
      ],
      where: '$orderTable.createdAt BETWEEN ? AND ?',
      whereArgs: [
        Util.toUTC(now: start),
        Util.toUTC(now: end),
      ],
      orderBy: '$orderTable.createdAt desc',
      limit: limit,
      offset: offset,
      join: const JoinQuery(
        hostTable: orderTable,
        guestTable: productTable,
        hostKey: 'id',
        guestKey: 'orderId',
      ),
      groupBy: '$productTable.orderId',
    );

    return rows.map((row) {
      final pn = (row['pn'] as String).split(Database.delimiter);
      final pc = (row['pc'] as String).split(Database.delimiter);

      return OrderObject.fromMap(
        row,
        IterableZip([pn, pc]).map(
          (e) => {'productName': e[0], 'count': int.tryParse(e[1])},
        ),
      );
    }).toList();
  }

  Future<OrderObject?> getOrder(int id) async {
    final rows = await Database.instance.query(orderTable, where: 'id = $id');
    if (rows.isEmpty) return null;

    final w = 'orderId = $id';
    final prods = await Database.instance.query(productTable, where: w);
    final ins = await Database.instance.query(ingredientTable, where: w);
    final attrs = await Database.instance.query(attributeTable, where: w);

    return OrderObject.fromMap(rows[0], prods, ins, attrs);
  }

  /// Push order to the DB.
  Future<void> push(OrderObject order) async {
    await Database.instance.transaction((txn) async {
      final orderMap = order.toMap();
      final id = await txn.insert(orderTable, orderMap);

      for (final product in order.products) {
        final map = product.toMap();
        map['orderId'] = id;
        map['createdAt'] = orderMap['createdAt'];
        final pid = await txn.insert(productTable, map);

        final batch = txn.batch();
        for (final ingredient in product.ingredients) {
          final map = ingredient.toMap();
          map['orderId'] = id;
          map['orderProductId'] = pid;
          map['createdAt'] = orderMap['createdAt'];
          batch.insert(ingredientTable, map);
        }
        await batch.commit(noResult: true);
      }

      final batch = txn.batch();
      for (final attr in order.attributes) {
        final map = attr.toMap();
        map['orderId'] = id;
        map['createdAt'] = orderMap['createdAt'];
        batch.insert(attributeTable, map);
      }
      await batch.commit(noResult: true);

      return id;
    });

    notifyListeners();
  }

  /// Update order and all the other artifacts.
  Future<void> update(OrderObject order) async {
    await Database.instance.transaction((txn) async {
      await txn.update(orderTable, order.toMap(), where: 'id = ${order.id}');

      for (final p in order.products) {
        await txn.update(productTable, p.toMap(), where: 'id = ${p.id}');
        for (final i in p.ingredients) {
          await txn.update(ingredientTable, i.toMap(), where: 'id = ${i.id}');
        }
      }

      for (final a in order.attributes) {
        await txn.update(attributeTable, a.toMap(), where: 'id = ${a.id}');
      }
    });

    notifyListeners();
  }

  /// Delete order and all the other artifacts.
  Future<void> delete(int id) async {
    await Database.instance.transaction((txn) async {
      await txn.delete(orderTable, where: 'id = ?', whereArgs: [id]);

      final w = 'orderId = $id';
      await txn.delete(productTable, where: w);
      await txn.delete(ingredientTable, where: w);
      await txn.delete(attributeTable, where: w);
    });

    notifyListeners();
  }

  /// Stash the order to recover later.
  ///
  /// It will also save the order attributes.
  Future<int> stash(OrderObject order) {
    return Database.instance.push(stashTable, order.toStashMap());
  }

  Future<List<OrderObject>> getStashedOrders({
    int offset = 0,
    int? limit = 10,
  }) async {
    final rows = await Database.instance.query(
      stashTable,
      orderBy: 'createdAt desc',
      limit: limit,
      offset: offset,
    );

    return rows.map((e) => OrderObject.fromStashMap(e)).toList();
  }

  Future<OrderObject?> getStashedOrder(int id) async {
    final rows = await Database.instance.query(stashTable, where: 'id = $id');
    if (rows.isEmpty) return null;

    final object = OrderObject.fromStashMap(rows[0]);

    await Database.instance.delete(stashTable, id);

    return object;
  }
}

/// Metrics from [Seller.getMetrics]
class OrderMetrics {
  /// Total count of orders in specific day range.
  final int count;

  /// Total price of orders in specific day range.
  final num price;

  /// Total cost of orders in specific day range.
  final num cost;

  /// Total revenue of orders in specific day range.
  final num revenue;

  /// How many rows in the table of products.
  final int? productCount;

  /// How many rows in the table of ingredients.
  final int? ingredientCount;

  /// How many rows in the table of order attributes.
  final int? attrCount;

  /// All required.
  const OrderMetrics._({
    required this.cost,
    required this.price,
    required this.count,
    required this.revenue,
    this.productCount,
    this.ingredientCount,
    this.attrCount,
  });

  /// Directly from DB data.
  factory OrderMetrics.fromMap(
    Map<String, Object?> map, {
    int? productCount,
    int? ingredientCount,
    int? attrCount,
  }) {
    return OrderMetrics._(
      count: map['count'] as int? ?? 0,
      price: map['price'] as num? ?? 0,
      cost: map['cost'] as num? ?? 0,
      revenue: map['revenue'] as num? ?? 0,
      productCount: productCount,
      ingredientCount: ingredientCount,
      attrCount: attrCount,
    );
  }
}
