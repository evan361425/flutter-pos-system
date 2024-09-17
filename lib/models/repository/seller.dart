import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/services/database.dart';

/// Help I/O from order DB.
class Seller extends ChangeNotifier {
  static const orderTable = 'order_records';

  static const productTable = 'order_products';

  static const ingredientTable = 'order_ingredients';

  static const attributeTable = 'order_attributes';

  /// Singleton object.
  static Seller instance = Seller._();

  Seller._();

  /// Get the metrics(e.g. count, price) of orders from time range.
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
          'SUM(price) revenue',
          'SUM(cost) cost',
          'SUM(revenue) profit',
        ],
        where: 'createdAt BETWEEN ? AND ?',
        whereArgs: [begin, finish],
      ),
    ];

    if (countingAll) {
      queries.addAll([
        Database.instance.query(
          productTable,
          columns: ['COUNT(*) count'],
          where: 'createdAt BETWEEN ? AND ?',
          whereArgs: [begin, finish],
        ),
        Database.instance.query(
          ingredientTable,
          columns: ['COUNT(*) count'],
          where: 'createdAt BETWEEN ? AND ?',
          whereArgs: [begin, finish],
        ),
        Database.instance.query(
          attributeTable,
          columns: ['COUNT(*) count'],
          where: 'createdAt BETWEEN ? AND ?',
          whereArgs: [begin, finish],
        ),
      ]);
    }

    final result = await Future.wait(queries);

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
  }

  /// Get the metric of orders grouped by the day.
  ///
  /// - [types] is the metrics type to calculate.
  /// - [interval] is the time interval to group by.
  /// - [ignoreEmpty] whether to ignore the empty day.
  Future<List<OrderSummary>> getMetricsInPeriod(
    DateTime start,
    DateTime end, {
    List<OrderMetricType> types = const [OrderMetricType.count],
    MetricsIntervalType interval = MetricsIntervalType.day,
    bool ignoreEmpty = true,
    String orderDirection = 'asc',
    int? limit,
  }) async {
    // using UTC to calculate the count but use user's timezone when returned.
    final begin = Util.toUTC(now: start);
    final cease = Util.toUTC(now: end);

    final rows = await Database.instance.query(
      '('
      'SELECT CAST((createdAt - $begin) / ${interval.seconds} AS INT) day, * '
      'FROM $orderTable '
      'WHERE createdAt BETWEEN $begin AND $cease'
      ') t',
      columns: [
        'day',
        ...types.map((e) => '${e.method}(${e.column}) ${e.name}'),
      ],
      groupBy: "day",
      orderBy: "day $orderDirection",
      limit: limit,
      escapeTable: false,
    );

    final result = <OrderSummary>[
      for (final row in rows)
        if (row['day'] != null)
          OrderSummary(
            at: Util.fromUTC(begin + (row['day'] as int) * interval.seconds),
            values: row.cast<String, num>(),
          ),
    ];

    return ignoreEmpty ? result : _fulfillPeriodData(start, end, Duration(seconds: interval.seconds), result);
  }

  /// Get the metric of items grouped by the day.
  ///
  /// - [target] is the target of catalog to group by.
  /// - [interval] is the time interval to group by.
  /// - [selection] is the specific items to group by.
  /// - [ignoreEmpty] whether to ignore the empty day.
  Future<List<OrderSummary>> getItemMetricsInPeriod(
    DateTime start,
    DateTime end, {
    required OrderMetricType type,
    required OrderMetricTarget target,
    MetricsIntervalType interval = MetricsIntervalType.day,
    List<String> selection = const [],
    bool ignoreEmpty = true,
  }) async {
    // using UTC to calculate the count but use user's timezone when returned.
    final begin = Util.toUTC(now: start);
    final cease = Util.toUTC(now: end);

    final where = selection.isEmpty ? '' : ' AND ${target.filterColumn} IN ("${selection.join('","')}")';
    // if target has different column then we need to concat the column to
    // make the result more readable.
    // (different catalog may have same item name).
    // take order attribute as example:
    // plasticSpoon(yes), withBag(yes) both have same attribute: `yes`
    final name = target.isGroupedName(selection)
        ? "`${target.groupColumn}` || '(' || `${target.filterColumn}` || ')'"
        : target.groupColumn;

    final rows = await Database.instance.query(
      '('
      'SELECT CAST((createdAt - $begin) / ${interval.seconds} AS INT) day, * '
      'FROM ${target.table} '
      'WHERE createdAt BETWEEN $begin AND $cease $where '
      ') t',
      columns: [
        'day',
        '$name name',
        '${type.method}(${type.targetColumn}) value',
      ],
      groupBy: "day, ${target.groupColumn}",
      orderBy: "day asc",
      escapeTable: false,
    );

    final result = rows
        .where((e) => e['day'] != null)
        .groupListsBy((row) => row['day'])
        .values
        .map((e) => OrderSummary(
              at: Util.fromUTC(begin + (e.first['day'] as int) * interval.seconds),
              values: {
                for (final row in e) row['name'] as String: row['value'] as num,
              },
            ))
        .toList();

    return ignoreEmpty ? result : _fulfillPeriodData(start, end, Duration(seconds: interval.seconds), result);
  }

  /// Get the metrics of orders and group by the items.
  ///
  /// select all if [selection] is empty.
  Future<List<OrderMetricPerItem>> getMetricsByItems(
    DateTime start,
    DateTime end, {
    required OrderMetricType type,
    required OrderMetricTarget target,
    List<String> selection = const [],
    bool ignoreEmpty = false,
  }) async {
    final begin = Util.toUTC(now: start);
    final cease = Util.toUTC(now: end);

    final where = selection.isEmpty ? '' : ' AND `${target.filterColumn}` IN ("${selection.join('","')}")';

    final rows = await Database.instance.query(
      target.table,
      columns: [
        '${target.groupColumn} name',
        '${type.method}(${type.targetColumn}) value',
      ],
      where: 'createdAt BETWEEN ? AND ?$where',
      whereArgs: [begin, cease],
      groupBy: target.groupColumn,
      orderBy: 'value desc',
    );

    final total = rows.fold(0.0, (prev, e) => prev + (e['value'] as num));
    final result = <OrderMetricPerItem>[
      for (final row in rows)
        OrderMetricPerItem(
          row['name'] as String,
          row['value'] as num,
          total,
        ),
    ];

    if (ignoreEmpty) {
      return result;
    }

    return target
        .getItems(selection)
        .map((item) => result.where((e) => e.name == item.name).firstOrNull ?? OrderMetricPerItem(item.name, 0, total))
        .toList();
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
  Future<List<OrderObject>> getDetailedOrders(DateTime start, DateTime end) async {
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

  List<OrderSummary> _fulfillPeriodData(
    DateTime start,
    DateTime end,
    Duration interval,
    List<OrderSummary> data,
  ) {
    var i = 0;
    return <OrderSummary>[
      for (var v = start; v.isBefore(end); v = v.add(interval))
        // `result is not enough` or `result has not contains the day`
        i >= data.length || data[i].at != v ? OrderSummary(at: v) : data[i++],
    ];
  }
}

/// Metrics from [Seller.getMetrics]
class OrderMetrics {
  /// Total count of orders in specific day range.
  final int count;

  /// Total revenue of orders in specific day range.
  final num revenue;

  /// Total cost of orders in specific day range.
  final num cost;

  /// Total (net) profit of orders in specific day range.
  final num profit;

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
    required this.revenue,
    required this.count,
    required this.profit,
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
      revenue: map['revenue'] as num? ?? 0,
      cost: map['cost'] as num? ?? 0,
      profit: map['profit'] as num? ?? 0,
      productCount: productCount,
      ingredientCount: ingredientCount,
      attrCount: attrCount,
    );
  }
}

class OrderSummary {
  final DateTime at;

  final Map<String, num> values;

  const OrderSummary({
    required this.at,
    this.values = const {},
  });

  num value(String key) {
    return values[key] ?? 0;
  }

  int get count => value('count').toInt();

  num get revenue => value('revenue');

  num get cost => value('cost');

  num get profit => value('profit');
}

class OrderMetricPerItem {
  final String name;
  final num value;
  final double percent;

  OrderMetricPerItem(this.name, this.value, num total) : percent = total == 0 ? 0 : value / total;
}

enum OrderMetricUnit {
  money(r'${value}', r'$point.y'),
  count(r'{value}', r'point.y');

  final String labelFormat;
  final String tooltipFormat;

  const OrderMetricUnit(this.labelFormat, this.tooltipFormat);
}

enum OrderMetricType {
  revenue('SUM', 'price', 'singlePrice * count', OrderMetricUnit.money),
  cost('SUM', 'cost', 'singleCost * count', OrderMetricUnit.money),
  // profit = price - cost, we use `revenue` for historical reason.
  profit('SUM', 'revenue', '(singlePrice - singleCost) * count', OrderMetricUnit.money),
  count('COUNT', 'price', '*', OrderMetricUnit.count);

  /// The method to calculate the value in DB.
  final String method;

  /// The source column to execute [method].
  final String column;

  /// Target item column.
  final String targetColumn;

  /// The unit on chart.
  final OrderMetricUnit unit;

  const OrderMetricType(
    this.method,
    this.column,
    this.targetColumn,
    this.unit,
  );
}

enum OrderMetricTarget {
  order(Seller.orderTable, '', ''),
  catalog(Seller.productTable, 'catalogName', 'catalogName'),
  product(Seller.productTable, 'productName', 'productName'),
  ingredient(Seller.ingredientTable, 'ingredientName', 'ingredientName'),
  attribute(Seller.attributeTable, 'name', 'optionName');

  /// The table name in DB.
  final String table;

  /// The column use on `where` syntax in DB.
  final String filterColumn;

  /// The column use on `group` syntax in DB.
  final String groupColumn;

  const OrderMetricTarget(this.table, this.filterColumn, this.groupColumn);

  /// Whether the filter column is different from the group column.
  bool get hasDifferentColumn => filterColumn != groupColumn;

  /// Whether append parenthesis to the name when grouped.
  bool isGroupedName(List<String> selection) => hasDifferentColumn && selection.length != 1;

  /// Get the items from the target.
  ///
  /// - [selection] null and empty means select all
  List<Model> getItems([List<String>? selection]) {
    late final List<Model> result;
    switch (this) {
      case OrderMetricTarget.product:
        result = Menu.instance.products.toList();
        break;
      case OrderMetricTarget.catalog:
        result = Menu.instance.itemList;
        break;
      case OrderMetricTarget.ingredient:
        result = Stock.instance.itemList;
        break;
      case OrderMetricTarget.attribute:
        if (selection != null) {
          if (selection.isEmpty) {
            return OrderAttributes.instance.itemList.expand((e) => e.itemList).toList();
          }

          return selection
              .expand<OrderAttributeOption>((id) => OrderAttributes.instance.getItemByName(id)?.itemList ?? const [])
              .toList();
        }

        result = OrderAttributes.instance.itemList;
        break;
      default:
        return const [];
    }

    // null and empty means select all
    if (selection == null || selection.isEmpty) {
      return result;
    }

    return result.where((e) => selection.contains(e.name)).toList();
  }
}

enum MetricsIntervalType {
  hour(3600, 'HH:mm a'),
  day(86400, 'MMMEd'),
  month(2592000, 'MMMd');

  final int seconds;
  final String format;

  factory MetricsIntervalType.fromDays(int days) {
    if (days > 62) {
      return month;
    }

    if (days > 2) {
      return day;
    }

    return hour;
  }

  const MetricsIntervalType(this.seconds, this.format);
}
