import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/percentile_bar.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/ui/analysis/widgets/analysis_card.dart';

class AnalysisView extends StatelessWidget {
  final TutorialInTab? tab;

  const AnalysisView({Key? key, this.tab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TutorialWrapper(
      tab: tab,
      child: ListView(children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          RouteCircularButton(
            key: Key('anal.order'),
            icon: Icons.store_sharp,
            route: Routes.order,
            text: '點餐',
          ),
          SizedBox.square(dimension: 96.0),
          RouteCircularButton(
            key: Key('anal.history'),
            icon: Icons.calendar_month_sharp,
            route: Routes.history,
            text: '紀錄',
          ),
        ]),
        const SizedBox(height: 4.0),
        metricsCard,
        // TODO: 折線圖、圓餅圖
      ]),
    );
  }

  Widget get metricsCard {
    return AnalysisCard<OrderMetrics>(
      builder: (context, metric) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('銷售', style: Theme.of(context).textTheme.headlineSmall),
          // TODO: add target
          PercentileBar(metric.price, 0),
          const SizedBox(height: 8.0),
          MetaBlock.withString(context, [
            '成本：${metric.cost.toCurrency()}',
            '盈利：${(metric.price - metric.cost).toCurrency()}',
          ])!,
        ]);
      },
      loader: () {
        final range = Util.getDateRange();
        return Seller.instance.getMetrics(
          range.start,
          range.end,
        );
      },
    );
  }
}
