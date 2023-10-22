import 'package:flutter/material.dart';
import 'package:possystem/components/style/head_tail_tile.dart';
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
      id: 'summarize',
      notifier: Seller.instance,
      builder: (context, metric) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('銷售', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4.0),
          // TODO: add target
          HeadTailTile(head: '訂單數', tail: metric.count.toString()),
          HeadTailTile(head: '營收', tail: metric.price.toCurrency()),
          HeadTailTile(head: '成本', tail: metric.cost.toCurrency()),
          HeadTailTile(head: '利潤', tail: metric.revenue.toCurrency()),
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
