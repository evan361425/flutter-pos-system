import 'package:collection/collection.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller/metric_enums.dart';
import 'package:possystem/models/repository/seller/shift_report_queries.dart';
import 'package:possystem/models/shift/shift_report.dart';
import 'package:possystem/services/database.dart';

/// Read-only analytics queries against the four order tables.
///
/// Extracted from the former God Object so all reporting SQL lives in one
/// place, has zero write side-effects, and is trivial to mock in tests.
/// Every method returns pure data (records, DTOs) — nothing mutates state.
class SellerAnalyticsQueries {
  static final SellerAnalyticsQueries instance = SellerAnalyticsQueries._();

  SellerAnalyticsQueries._();

  /// Z-report metrics for a cash-register shift (delegates — Law 1.1).
  Future<ShiftReport> getShiftReport(String shiftId) =>
      ShiftReportQueries.instance.getShiftReport(shiftId);

  /// Get the metrics(e.g. count, price) of orders from time range.
  Future<OrderMetrics> getMetrics(
    DateTime start,
    DateTime end, {
    bool countingAll = false,
  }) async {
    final begin = Util.toUTC(now: start);
    final finish = Util.toUTC(now: end);

    // Single query with UNION ALL to get all counts in one roundtrip
    final result = await Database.instance.query(
      '''
      SELECT 
        (SELECT COUNT(*) FROM ${SellerTables.order} WHERE createdAt BETWEEN ? AND ?) as order_count,
        (SELECT SUM(price) FROM ${SellerTables.order} WHERE createdAt BETWEEN ? AND ?) as revenue,
        (SELECT SUM(cost) FROM ${SellerTables.order} WHERE createdAt BETWEEN ? AND ?) as cost,
        (SELECT SUM(revenue) FROM ${SellerTables.order} WHERE createdAt BETWEEN ? AND ?) as profit,
        (SELECT COUNT(*) FROM ${SellerTables.product} WHERE createdAt BETWEEN ? AND ?) as product_count,
        (SELECT COUNT(*) FROM ${SellerTables.ingredient} WHERE createdAt BETWEEN ? AND ?) as ingredient_count,
        (SELECT COUNT(*) FROM ${SellerTables.attribute} WHERE createdAt BETWEEN ? AND ?) as attr_count
      ''',
      whereArgs: [
        begin, finish, // order_count
        begin, finish, // revenue
        begin, finish, // cost
        begin, finish, // profit
        begin, finish, // product_count
        begin, finish, // ingredient_count
        begin, finish, // attr_count
      ],
      escapeTable: false,
    );

    final row = result[0];
    final orderMeta = {
      'count': row['order_count'],
      'revenue': row['revenue'],
      'cost': row['cost'],
      'profit': row['profit'],
    };

    int? productCount;
    int? ingredientCount;
    int? attrCount;
    if (countingAll && (orderMeta['count'] as int? ?? 0) != 0) {
      productCount = row['product_count'] as int?;
      ingredientCount = row['ingredient_count'] as int?;
      attrCount = row['attr_count'] as int?;
    }

    return OrderMetrics.fromMap(
      orderMeta,
      productCount: productCount,
      ingredientCount: ingredientCount,
      attrCount: attrCount,
    );
  }

  /// Get the metric of orders grouped by the day.
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
    final intervalSeconds = interval.seconds;

    final rows = await Database.instance.query(
      '('
      'SELECT CAST((createdAt - ?) / ? AS INT) day, * '
      'FROM ${SellerTables.order} '
      'WHERE createdAt BETWEEN ? AND ?'
      ') t',
      columns: [
        'day',
        ...types.map((e) => '${e.method}(${e.column}) ${e.name}'),
      ],
      whereArgs: [begin, intervalSeconds, begin, cease],
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

    return ignoreEmpty
        ? result
        : _fulfillPeriodData(
            start,
            end,
            Duration(seconds: interval.seconds),
            result,
          );
  }

  /// Get the metric of items grouped by the day.
  Future<List<OrderSummary>> getItemMetricsInPeriod(
    DateTime start,
    DateTime end, {
    required OrderMetricType type,
    required OrderMetricTarget target,
    MetricsIntervalType interval = MetricsIntervalType.day,
    List<String> selection = const [],
    bool ignoreEmpty = true,
  }) async {
    final begin = Util.toUTC(now: start);
    final cease = Util.toUTC(now: end);
    final intervalSeconds = interval.seconds;

    // Build parameterized WHERE clause for selection (Law 2.1: never
    // interpolate user data into SQL strings).
    String whereClause = '';
    List<Object?> whereArgs = [begin, intervalSeconds, begin, cease];

    if (selection.isNotEmpty) {
      final placeholders = selection.map((_) => '?').join(',');
      whereClause = ' AND ${target.filterColumn} IN ($placeholders)';
      whereArgs.addAll(selection);
    }

    // if target has different column then we need to concat the column to
    // make the result more readable (different catalog may have same item
    // name). take order attribute as example: plasticSpoon(yes), withBag(yes)
    // both have same attribute: `yes`.
    final name = target.isGroupedName(selection)
        ? "`${target.groupColumn}` || '(' || `${target.filterColumn}` || ')'"
        : target.groupColumn;

    final rows = await Database.instance.query(
      '('
      'SELECT CAST((createdAt - ?) / ? AS INT) day, * '
      'FROM ${target.table} '
      'WHERE createdAt BETWEEN ? AND ?$whereClause '
      ') t',
      columns: [
        'day',
        '$name name',
        '${type.method}(${type.targetColumn}) value',
      ],
      whereArgs: whereArgs,
      groupBy: "day, ${target.groupColumn}",
      orderBy: "day asc",
      escapeTable: false,
    );

    final result = rows
        .where((e) => e['day'] != null)
        .groupListsBy((row) => row['day'])
        .values
        .map(
          (e) => OrderSummary(
            at: Util.fromUTC(
              begin + (e.first['day'] as int) * interval.seconds,
            ),
            values: {
              for (final row in e) row['name'] as String: row['value'] as num,
            },
          ),
        )
        .toList();

    return ignoreEmpty
        ? result
        : _fulfillPeriodData(
            start,
            end,
            Duration(seconds: interval.seconds),
            result,
          );
  }

  /// Get the metrics of orders and group by the items.
  ///
  /// Select all if [selection] is empty.
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

    String whereClause = '';
    List<Object?> whereArgs = [begin, cease];

    if (selection.isNotEmpty) {
      final placeholders = selection.map((_) => '?').join(',');
      whereClause = ' AND `${target.filterColumn}` IN ($placeholders)';
      whereArgs.addAll(selection);
    }

    final rows = await Database.instance.query(
      target.table,
      columns: [
        '${target.groupColumn} name',
        '${type.method}(${type.targetColumn}) value',
      ],
      where: 'createdAt BETWEEN ? AND ?$whereClause',
      whereArgs: whereArgs,
      groupBy: target.groupColumn,
      orderBy: 'value desc',
    );

    final total = rows.fold(0.0, (prev, e) => prev + (e['value'] as num));
    final result = <OrderMetricPerItem>[
      for (final row in rows)
        OrderMetricPerItem(row['name'] as String, row['value'] as num, total),
    ];

    if (ignoreEmpty) {
      return result;
    }

    return target
        .getItems(selection)
        .map(
          (item) =>
              result.where((e) => e.name == item.name).firstOrNull ??
              OrderMetricPerItem(item.name, 0, total),
        )
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
      SellerTables.order,
      columns: [
        '${SellerTables.order}.*',
        'GROUP_CONCAT(${SellerTables.product}.productName, ${Database.queryDelimiter}) AS pn',
        'GROUP_CONCAT(${SellerTables.product}.count, ${Database.queryDelimiter}) AS pc',
      ],
      where: '${SellerTables.order}.createdAt BETWEEN ? AND ?',
      whereArgs: [
        Util.toUTC(now: start),
        Util.toUTC(now: end),
      ],
      orderBy: '${SellerTables.order}.createdAt desc',
      limit: limit,
      offset: offset,
      join: const JoinQuery(
        hostTable: SellerTables.order,
        guestTable: SellerTables.product,
        hostKey: 'id',
        guestKey: 'orderId',
      ),
      groupBy: '${SellerTables.product}.orderId',
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
    DateTime start,
    DateTime end,
  ) async {
    final r = await Database.instance.transaction((txn) async {
      final batch = txn.batch();
      queryTable(String t) {
        batch.query(
          t,
          where: 'createdAt BETWEEN ? AND ?',
          whereArgs: [Util.toUTC(now: start), Util.toUTC(now: end)],
          orderBy: 'createdAt asc',
        );
      }

      queryTable(SellerTables.order);
      queryTable(SellerTables.product);
      queryTable(SellerTables.ingredient);
      queryTable(SellerTables.attribute);

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
    final rows = await Database.instance.query(
      SellerTables.order,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;

    final w = 'orderId = ?';
    final r = await Database.instance.transaction((txn) async {
      final batch = txn.batch();
      batch.query(SellerTables.product, where: w, whereArgs: [id]);
      batch.query(SellerTables.ingredient, where: w, whereArgs: [id]);
      batch.query(SellerTables.attribute, where: w, whereArgs: [id]);

      return (await batch.commit()).cast<List<Map<String, Object?>>>();
    });

    return OrderObject.fromMap(rows[0], r[0], r[1], r[2]);
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
