import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/services/analysis/dashboard_service.dart';

/// KPI strip: total sales, order count, average ticket.
class DashboardKpiRow extends StatelessWidget {
  const DashboardKpiRow({super.key, required this.metrics});

  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 640;
          final cards = [
            _KpiCard(
              key: const Key('dashboard.kpi.sales'),
              icon: Icons.payments_outlined,
              label: 'Total sales',
              value: metrics.totalSales.toCurrency(),
            ),
            _KpiCard(
              key: const Key('dashboard.kpi.orders'),
              icon: Icons.receipt_long_outlined,
              label: 'Orders',
              value: '${metrics.orderCount}',
            ),
            _KpiCard(
              key: const Key('dashboard.kpi.avg'),
              icon: Icons.shopping_bag_outlined,
              label: 'Avg ticket',
              value: metrics.averageTicket.toCurrency(),
            ),
          ];

          if (wide) {
            return Row(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: cards[i]),
                ],
              ],
            );
          }

          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                cards[i],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
