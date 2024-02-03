import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Help I/O from order DB.
class Seller extends ChangeNotifier {
  static const orderTable = 'order_records';

  static const productTable = 'order_products';

  static const ingredientTable = 'order_ingredients';

  static const attributeTable = 'order_attributes';

  /// Singleton object.
  static Seller instance = Seller._();

  Seller._();

  /// Get the metric of orders grouped by the day.
  ///
  /// [types] is the metrics type to calculate.
  /// [period] is the time interval to group by.
  /// [fulfillAll] is to fulfill the missing day in the period.
  Future<List<OrderMetricPerDay>> getMetricsInPeriod(
    DateTime start,
    DateTime end, {
    List<OrderMetricsType> types = const [OrderMetricsType.count],
    MetricsPeriod period = MetricsPeriod.day,
    bool fulfillAll = false,
  }) async {
    // using UTC to calculate the count but use user's timezone when returned.
    final begin = Util.toUTC(now: start);
    final cease = Util.toUTC(now: end);

    // get SQL column names
    final notCount = types.where((e) => e.method != 'COUNT');
    final isCount = types.where((e) => e.method == 'COUNT');
    final srcCols = [
      'day',
      ...notCount.map((e) => e.column),
    ].join(', ');
    final dstCols = [
      't.day',
      ...isCount.map((e) => 'COUNT(*) count'),
      ...notCount.map((e) => '${e.method}(t.${e.column}) ${e.column}'),
    ];

    final rows = await Database.instance.query(
      '('
      'SELECT CAST((createdAt - $begin) / ${period.seconds} AS INT) $srcCols '
      'FROM $orderTable '
      'WHERE createdAt BETWEEN $begin AND $cease'
      ') t',
      columns: dstCols,
      groupBy: "t.day",
      orderBy: "t.day asc",
      escapeTable: false,
    );

    final result = <OrderMetricPerDay>[
      for (final row in rows)
        if (row['day'] != null)
          OrderMetricPerDay(
            at: Util.fromUTC(begin + (row['day'] as int) * period.seconds),
            count: row['count'] as int?,
            price: row['price'] as num?,
            cost: row['cost'] as num?,
            revenue: row['revenue'] as num?,
          ),
    ];
    if (!fulfillAll) {
      return result;
    }

    var i = 0;
    final fulfilled = <OrderMetricPerDay>[];
    for (var v = start; v.isBefore(end); v = v.add(const Duration(days: 1))) {
      // fulfill the missing day
      if (i >= result.length || result[i].at != v) {
        fulfilled.add(OrderMetricPerDay(at: v));
      } else {
        fulfilled.add(result[i]);
        i++;
      }
    }

    return fulfilled;
  }

  /// Get the metrics of orders from time range.
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
    int limit = 10,
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
      final pn = (row['pn'] as String? ?? '').split(Database.delimiter);
      final pc = (row['pc'] as String? ?? '').split(Database.delimiter);

      return OrderObject.fromMap(
        row,
        IterableZip([pn, pc]).map(
          (e) => {'productName': e[0], 'count': int.tryParse(e[1])},
        ),
      );
    }).toList();
  }

  /// Get orders in all detailed set.
  ///
  /// This is used to export orders.
  Future<List<OrderObject>> getDetailedOrders(
      DateTime start, DateTime end) async {
    final r = await Database.instance.transaction((txn) async {
      final batch = txn.batch();
      queryTable(String t) {
        batch.query(
          t,
          where: 'createdAt BETWEEN ? AND ?',
          whereArgs: [
            Util.toUTC(now: start),
            Util.toUTC(now: end),
          ],
          orderBy: 'createdAt asc',
        );
      }

      queryTable(orderTable);
      queryTable(productTable);
      queryTable(ingredientTable);
      queryTable(attributeTable);

      return (await batch.commit()).cast<List<Map<String, Object?>>>();
    });

    final rr = [r[1], r[2], r[3]];

    return r[0].map((order) {
      final id = order['id'];
      final pi = _getSizeBelongsToOrder(rr[0], id);
      final ii = _getSizeBelongsToOrder(rr[1], id);
      final ai = _getSizeBelongsToOrder(rr[2], id);
      final o = OrderObject.fromMap(
        order,
        rr[0].sublist(0, pi),
        rr[1].sublist(0, ii),
        rr[2].sublist(0, ai),
      );
      rr[0] = rr[0].sublist(pi);
      rr[1] = rr[1].sublist(ii);
      rr[2] = rr[2].sublist(ai);

      return o;
    }).toList();
  }

  /// Get the specific order by id and return null if not exist.
  Future<OrderObject?> getOrder(int id) async {
    final rows = await Database.instance.query(orderTable, where: 'id = $id');
    if (rows.isEmpty) return null;

    final w = 'orderId = $id';
    final r = await Database.instance.transaction((txn) async {
      final batch = txn.batch();
      batch.query(productTable, where: w);
      batch.query(ingredientTable, where: w);
      batch.query(attributeTable, where: w);

      return (await batch.commit()).cast<List<Map<String, Object?>>>();
    });

    return OrderObject.fromMap(rows[0], r[0], r[1], r[2]);
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

  /// Delete order and all the other artifacts.
  Future<void> delete(int id) async {
    await Database.instance.transaction((txn) async {
      await txn.delete(orderTable, where: 'id = $id');

      final w = 'orderId = $id';
      await txn.delete(productTable, where: w);
      await txn.delete(ingredientTable, where: w);
      await txn.delete(attributeTable, where: w);
    });

    notifyListeners();
  }

  int _getSizeBelongsToOrder(List<Map<String, Object?>> items, Object? id) {
    for (var i = 0; i < items.length; i++) {
      if (items[i]['orderId'] != id) {
        return i;
      }
    }
    return items.length;
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

  /// Different mode may have optional attributes.
  ///
  /// see detailed in [Seller.getMetrics].
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

class OrderMetricPerDay {
  final DateTime at;

  final int? count;
  final num? price;
  final num? cost;
  final num? revenue;

  const OrderMetricPerDay({
    required this.at,
    this.count,
    this.price,
    this.cost,
    this.revenue,
  });

  num valueFromType(OrderMetricsType t) {
    switch (t) {
      case OrderMetricsType.count:
        return count ?? 0;
      case OrderMetricsType.price:
        return price ?? 0;
      case OrderMetricsType.cost:
        return cost ?? 0;
      case OrderMetricsType.revenue:
        return revenue ?? 0;
    }
  }
}

enum OrderMetricsType {
  count('COUNT', 'count', null, '訂單數'),
  price('SUM', 'price', r'${value}', '營收'),
  cost('SUM', 'cost', r'${value}', '成本'),
  revenue('SUM', 'revenue', r'${value}', '盈利');

  /// The method to calculate the value in DB.
  final String method;

  /// The column name in DB.
  final String column;

  /// The label on chart.
  final String? label;

  /// The title of the series.
  final String title;

  const OrderMetricsType(
    this.method,
    this.column,
    this.label,
    this.title,
  );
}

enum MetricsPeriod {
  hour(3600, 'HH:mm a', DateTimeIntervalType.hours),
  day(86400, 'MMMEd', DateTimeIntervalType.days),
  month(2592000, 'MMMd', DateTimeIntervalType.months);

  final int seconds;
  final String format;
  final DateTimeIntervalType intervalType;

  const MetricsPeriod(this.seconds, this.format, this.intervalType);
}
