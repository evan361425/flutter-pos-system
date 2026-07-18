import 'dart:convert';

import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller/metric_enums.dart';
import 'package:possystem/services/database.dart';

/// DTO: one local-hour bucket of sales activity.
class PeakHourMetric {
  const PeakHourMetric({
    required this.hour,
    required this.totalRevenue,
    required this.orderCount,
  });

  /// Local wall-clock hour in `[0, 23]`.
  final int hour;
  final num totalRevenue;
  final int orderCount;

  factory PeakHourMetric.fromMap(Map<String, Object?> map) {
    return PeakHourMetric(
      hour: int.tryParse(map['hour']?.toString() ?? '') ?? 0,
      totalRevenue: map['total_revenue'] as num? ?? 0,
      orderCount: (map['order_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// DTO: bestselling product line over a range.
class TopSellerMetric {
  const TopSellerMetric({
    required this.name,
    required this.quantitySold,
    required this.totalRevenue,
  });

  final String name;
  final int quantitySold;
  final num totalRevenue;

  factory TopSellerMetric.fromMap(Map<String, Object?> map) {
    return TopSellerMetric(
      name: map['name'] as String? ?? '',
      quantitySold: (map['quantity_sold'] as num?)?.toInt() ?? 0,
      totalRevenue: map['total_revenue'] as num? ?? 0,
    );
  }
}

/// DTO: revenue grouped by tender bucket (`cash` / `card` / `voucher` / `mixed`).
class PaymentMethodRevenue {
  const PaymentMethodRevenue({
    required this.method,
    required this.totalRevenue,
    required this.orderCount,
  });

  final String method;
  final num totalRevenue;
  final int orderCount;

  factory PaymentMethodRevenue.fromMap(Map<String, Object?> map) {
    return PaymentMethodRevenue(
      method: map['method'] as String? ?? 'cash',
      totalRevenue: map['total_revenue'] as num? ?? 0,
      orderCount: (map['order_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Optimized dashboard analytics (split from [SellerAnalyticsQueries] — Law 1.1).
///
/// [createdAt] is stored as **Unix seconds** via [Util.toUTC], not milliseconds.
/// Peak-hour bucketing uses `createdAt + tzOffsetSeconds` with
/// `strftime(..., 'unixepoch')` — never `createdAt / 1000`.
class DashboardQueries {
  DashboardQueries._();

  static final DashboardQueries instance = DashboardQueries._();

  /// Group orders by **local** hour of day within [[start], [end]].
  ///
  /// Timezone strategy:
  /// 1. Filter with `createdAt BETWEEN ? AND ?` after [Util.toUTC] (UTC seconds).
  /// 2. Bind `DateTime.now().timeZoneOffset.inSeconds` as a SQL param.
  /// 3. Bucket with `strftime('%H', createdAt + ?, 'unixepoch')` so "14"
  ///    means 14:00 on the store's wall clock, not UTC.
  Future<List<PeakHourMetric>> getPeakHours(
    DateTime start,
    DateTime end,
  ) async {
    final begin = Util.toUTC(now: start);
    final finish = Util.toUTC(now: end);
    final tzOffsetSeconds = DateTime.now().timeZoneOffset.inSeconds;
    final orderTable = SellerTables.order;

    final rows = await Database.instance.db.rawQuery(
      '''
      SELECT
        strftime('%H', createdAt + ?, 'unixepoch') AS hour,
        COALESCE(SUM(price), 0) AS total_revenue,
        COUNT(*) AS order_count
      FROM `$orderTable`
      WHERE createdAt BETWEEN ? AND ?
      GROUP BY hour
      ORDER BY hour ASC
      ''',
      [tzOffsetSeconds, begin, finish],
    );

    final byHour = <int, PeakHourMetric>{};
    for (final row in rows) {
      final metric = PeakHourMetric.fromMap(row);
      byHour[metric.hour] = metric;
    }

    // Dense 0–23 series for Syncfusion bar charts (missing hours = zero).
    return [
      for (var h = 0; h < 24; h++)
        byHour[h] ??
            PeakHourMetric(hour: h, totalRevenue: 0, orderCount: 0),
    ];
  }

  /// Top products by quantity sold (single `GROUP BY` — no N+1).
  Future<List<TopSellerMetric>> getTopSellers(
    DateTime start,
    DateTime end,
    int limit,
  ) async {
    final begin = Util.toUTC(now: start);
    final finish = Util.toUTC(now: end);
    final safeLimit = limit < 1 ? 5 : limit;
    final productTable = SellerTables.product;

    final rows = await Database.instance.db.rawQuery(
      '''
      SELECT
        productName AS name,
        COALESCE(SUM(count), 0) AS quantity_sold,
        COALESCE(SUM(count * singlePrice), 0) AS total_revenue
      FROM `$productTable`
      WHERE createdAt BETWEEN ? AND ?
      GROUP BY productName
      ORDER BY quantity_sold DESC
      LIMIT ?
      ''',
      [begin, finish, safeLimit],
    );

    return rows.map(TopSellerMetric.fromMap).toList();
  }

  /// Revenue by payment method via JSON1 `json_each` (Z-report pattern).
  ///
  /// Each order's [price] is counted once: single tender → that method,
  /// multi-tender → `mixed`. Falls back to one SELECT + Dart fold if JSON1
  /// is unavailable.
  Future<List<PaymentMethodRevenue>> getRevenueByPaymentMethod(
    DateTime start,
    DateTime end,
  ) async {
    final begin = Util.toUTC(now: start);
    final finish = Util.toUTC(now: end);

    try {
      return await _paymentMethodsJson1(begin, finish);
    } catch (e, stack) {
      Log.err(e, 'dashboard_payment_json1_fallback', stack);
      return _paymentMethodsDartFallback(begin, finish);
    }
  }

  /// KPI strip totals — one round-trip.
  Future<({num totalSales, int orderCount})> getKpiTotals(
    DateTime start,
    DateTime end,
  ) async {
    final begin = Util.toUTC(now: start);
    final finish = Util.toUTC(now: end);
    final orderTable = SellerTables.order;

    final rows = await Database.instance.db.rawQuery(
      '''
      SELECT
        COUNT(*) AS order_count,
        COALESCE(SUM(price), 0) AS total_sales
      FROM `$orderTable`
      WHERE createdAt BETWEEN ? AND ?
      ''',
      [begin, finish],
    );

    final row = rows.isEmpty ? const <String, Object?>{} : rows.first;
    return (
      totalSales: row['total_sales'] as num? ?? 0,
      orderCount: (row['order_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<PaymentMethodRevenue>> _paymentMethodsJson1(
    int begin,
    int finish,
  ) async {
    final orderTable = SellerTables.order;
    final rows = await Database.instance.db.rawQuery(
      '''
      WITH order_methods AS (
        SELECT
          o.id AS order_id,
          o.price AS price,
          COUNT(DISTINCT json_extract(p.value, '\$.method')) AS method_count,
          MIN(json_extract(p.value, '\$.method')) AS single_method
        FROM `$orderTable` AS o,
        json_each(
          CASE
            WHEN o.payments IS NOT NULL AND length(o.payments) > 2
              THEN o.payments
            ELSE json_array(json_object('amount', o.paid, 'method', 'cash'))
          END
        ) AS p
        WHERE o.createdAt BETWEEN ? AND ?
        GROUP BY o.id
      )
      SELECT
        CASE
          WHEN method_count > 1 THEN 'mixed'
          ELSE COALESCE(single_method, 'cash')
        END AS method,
        COALESCE(SUM(price), 0) AS total_revenue,
        COUNT(*) AS order_count
      FROM order_methods
      GROUP BY method
      ORDER BY total_revenue DESC
      ''',
      [begin, finish],
    );

    return rows.map(PaymentMethodRevenue.fromMap).toList();
  }

  Future<List<PaymentMethodRevenue>> _paymentMethodsDartFallback(
    int begin,
    int finish,
  ) async {
    final rows = await Database.instance.query(
      SellerTables.order,
      columns: const ['price', 'paid', 'payments'],
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [begin, finish],
    );

    final buckets = <String, ({num revenue, int count})>{};

    for (final row in rows) {
      final price = row['price'] as num? ?? 0;
      final methods = _methodsFromRow(row);
      final key = methods.length > 1
          ? 'mixed'
          : (methods.isEmpty ? 'cash' : methods.first);
      final prev = buckets[key] ?? (revenue: 0, count: 0);
      buckets[key] = (revenue: prev.revenue + price, count: prev.count + 1);
    }

    return [
      for (final e in buckets.entries)
        PaymentMethodRevenue(
          method: e.key,
          totalRevenue: e.value.revenue,
          orderCount: e.value.count,
        ),
    ]..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
  }

  Set<String> _methodsFromRow(Map<String, Object?> row) {
    final raw = row['payments'];
    if (raw is String && raw.length > 2) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List && decoded.isNotEmpty) {
          return {
            for (final item in decoded)
              if (item is Map) (item['method'] as String? ?? 'cash'),
          };
        }
      } catch (_) {
        // Fall through to legacy paid.
      }
    }
    return const {'cash'};
  }
}
