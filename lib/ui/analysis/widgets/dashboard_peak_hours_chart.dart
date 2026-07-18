import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller/dashboard_queries.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Peak-hours bar chart (local timezone buckets).
class DashboardPeakHoursChart extends StatelessWidget {
  const DashboardPeakHoursChart({super.key, required this.data});

  final List<PeakHourMetric> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = data.any((e) => e.orderCount > 0 || e.totalRevenue > 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peak hours', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Revenue by local hour of day',
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(
              height: 220,
              child: hasData
                  ? SfCartesianChart(
                      margin: const EdgeInsets.only(top: 16),
                      primaryXAxis: const CategoryAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        labelRotation: -45,
                      ),
                      primaryYAxis: NumericAxis(
                        majorGridLines: MajorGridLines(
                          width: 0.5,
                          color: theme.dividerColor,
                        ),
                        axisLine: const AxisLine(width: 0),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries<PeakHourMetric, String>>[
                        ColumnSeries<PeakHourMetric, String>(
                          dataSource: data,
                          xValueMapper: (m, _) =>
                              m.hour.toString().padLeft(2, '0'),
                          yValueMapper: (m, _) => m.totalRevenue,
                          name: 'Revenue',
                          color: theme.colorScheme.primary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          dataLabelMapper: (m, _) =>
                              m.totalRevenue > 0
                                  ? m.totalRevenue.toCurrency()
                                  : '',
                        ),
                      ],
                    )
                  : const Center(child: Text('No sales in this range')),
            ),
          ],
        ),
      ),
    );
  }
}
