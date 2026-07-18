import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller/dashboard_queries.dart';

/// Ranked list of top-selling products.
class DashboardTopSellersList extends StatelessWidget {
  const DashboardTopSellersList({super.key, required this.data});

  final List<TopSellerMetric> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top bestsellers', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'By quantity sold',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (data.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No products sold in this range')),
              )
            else
              for (var i = 0; i < data.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text('${i + 1}'),
                  ),
                  title: Text(
                    data[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('${data[i].quantitySold} sold'),
                  trailing: Text(
                    data[i].totalRevenue.toCurrency(),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
