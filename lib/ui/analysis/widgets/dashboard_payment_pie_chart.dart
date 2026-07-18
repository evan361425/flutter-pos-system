import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller/dashboard_queries.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Pie chart of revenue by payment method (+ Mixed).
class DashboardPaymentPieChart extends StatelessWidget {
  const DashboardPaymentPieChart({super.key, required this.data});

  final List<PaymentMethodRevenue> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = data.any((e) => e.totalRevenue > 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment mix', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Cash · Card · Voucher · Mixed',
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(
              height: 220,
              child: hasData
                  ? SfCircularChart(
                      legend: const Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap,
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CircularSeries<PaymentMethodRevenue, String>>[
                        DoughnutSeries<PaymentMethodRevenue, String>(
                          dataSource: data,
                          xValueMapper: (m, _) => _label(m.method),
                          yValueMapper: (m, _) => m.totalRevenue,
                          dataLabelMapper: (m, _) => m.totalRevenue.toCurrency(),
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                          ),
                          innerRadius: '55%',
                        ),
                      ],
                    )
                  : const Center(child: Text('No payments in this range')),
            ),
          ],
        ),
      ),
    );
  }

  static String _label(String method) => switch (method) {
    'cash' => 'Cash',
    'card' => 'Card',
    'voucher' => 'Voucher',
    'mixed' => 'Mixed',
    _ => method,
  };
}
