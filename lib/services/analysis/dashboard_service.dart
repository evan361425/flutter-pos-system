import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/repository/seller/dashboard_queries.dart';

/// Aggregated manager dashboard snapshot for a single [DateTimeRange].
class DashboardMetrics {
  const DashboardMetrics({
    required this.range,
    required this.totalSales,
    required this.orderCount,
    required this.averageTicket,
    required this.peakHours,
    required this.topSellers,
    required this.revenueByPaymentMethod,
    required this.fetchedAt,
  });

  final DateTimeRange range;
  final num totalSales;
  final int orderCount;
  final num averageTicket;
  final List<PeakHourMetric> peakHours;
  final List<TopSellerMetric> topSellers;
  final List<PaymentMethodRevenue> revenueByPaymentMethod;
  final DateTime fetchedAt;

  static DashboardMetrics empty(DateTimeRange range) => DashboardMetrics(
    range: range,
    totalSales: 0,
    orderCount: 0,
    averageTicket: 0,
    peakHours: [
      for (var h = 0; h < 24; h++)
        PeakHourMetric(hour: h, totalRevenue: 0, orderCount: 0),
    ],
    topSellers: const [],
    revenueByPaymentMethod: const [],
    fetchedAt: DateTime.now(),
  );
}

/// Facade for manager dashboard analytics (Law 1.2).
///
/// Loads [DashboardMetrics] via [DashboardQueries] and keeps an in-memory
/// TTL cache (5 minutes) so back/forth navigation does not hammer SQLite.
class DashboardService {
  DashboardService._();

  static final DashboardService instance = DashboardService._();

  static const Duration cacheTtl = Duration(minutes: 5);
  static const int defaultTopSellersLimit = 5;

  final Map<String, DashboardMetrics> _cache = {};

  /// Fetch (or return cached) metrics for [range].
  Future<DashboardMetrics> fetchDashboardMetrics(DateTimeRange range) async {
    final key = _cacheKey(range);
    final cached = _cache[key];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < cacheTtl) {
      return cached;
    }

    try {
      final queries = DashboardQueries.instance;
      final kpiFuture = queries.getKpiTotals(range.start, range.end);
      final peakFuture = queries.getPeakHours(range.start, range.end);
      final topFuture = queries.getTopSellers(
        range.start,
        range.end,
        defaultTopSellersLimit,
      );
      final payFuture = queries.getRevenueByPaymentMethod(
        range.start,
        range.end,
      );

      final kpi = await kpiFuture;
      final peakHours = await peakFuture;
      final topSellers = await topFuture;
      final payments = await payFuture;

      final metrics = DashboardMetrics(
        range: range,
        totalSales: kpi.totalSales,
        orderCount: kpi.orderCount,
        averageTicket:
            kpi.orderCount == 0 ? 0 : kpi.totalSales / kpi.orderCount,
        peakHours: peakHours,
        topSellers: topSellers,
        revenueByPaymentMethod: payments,
        fetchedAt: DateTime.now(),
      );

      _cache[key] = metrics;
      Log.ger('dashboard_metrics_loaded', {
        'orders': metrics.orderCount,
        'sales': metrics.totalSales,
      });
      return metrics;
    } catch (e, stack) {
      Log.err(e, 'dashboard_metrics_failed', stack);
      return DashboardMetrics.empty(range);
    }
  }

  /// Drop all cached snapshots (e.g. after checkout volume in tests).
  void invalidateCache() => _cache.clear();

  String _cacheKey(DateTimeRange range) =>
      '${range.start.millisecondsSinceEpoch}_${range.end.millisecondsSinceEpoch}';
}
