import 'package:flutter/material.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/ui/analysis/widgets/reloadable_card.dart';

class GoalsCardView extends StatelessWidget {
  const GoalsCardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReloadableCard<OrderMetricPerDay>(
      id: 'goals',
      title: '目標',
      notifier: Seller.instance,
      builder: (context, metric) {
        final style = Theme.of(context).textTheme.bodyLarge;
        final goals = <Widget>[
          _GoalItem(
            type: OrderMetricsType.count,
            current: metric.count ?? 0,
            style: style,
            name: '訂單數',
            desc:
                '訂單數反映了產品對顧客的吸引力。它代表了市場對你產品的需求程度，能幫助你了解何種產品或時段最受歡迎。高訂單數可能意味著你的定價策略或行銷活動取得成功，是商業模型有效性的指標之一。但要注意，單純追求高訂單數可能會忽略盈利能力。',
          ),
          _GoalItem(
            type: OrderMetricsType.price,
            current: metric.price ?? 0,
            style: style,
            name: '營收',
            desc:
                '營收代表總銷售額，是業務規模的指標。高營收可能顯示了你的產品受歡迎且銷售良好，但營收無法反映出業務的可持續性和盈利能力。它不考慮成本和利潤，因此單純追求高營收可能會忽視實際利潤狀況。',
          ),
          _GoalItem(
            type: OrderMetricsType.revenue,
            current: metric.revenue ?? 0,
            style: style,
            name: '盈利',
            desc:
                '盈利是店家能否持續經營的關鍵。盈利直接反映了營運效率和成本管理能力。不同於營收，盈利考慮了生意的開支，包括原料成本、人力、租金等，這是一個更實際的指標，能幫助你評估經營是否有效且可持續。即使有高營收，但如果成本高於營收，最終可能面臨經營困境。',
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('成本', style: style),
              Text(metric.cost?.prettyString() ?? '0', style: style),
            ],
          ),
        ];

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: goals,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: CircularProgressIndicator(
                    value: 0.3,
                    color: Colors.pink,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    strokeWidth: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loader: () async {
        final range = Util.getDateRange();
        final result = await Seller.instance.getMetricsInPeriod(
          range.start,
          range.end,
          types: [
            OrderMetricsType.count,
            OrderMetricsType.price,
            OrderMetricsType.revenue,
            OrderMetricsType.cost,
          ],
          period: MetricsPeriod.day,
          fulfillAll: true,
        );

        return result[0];
      },
    );
  }
}

class _GoalItem extends StatelessWidget {
  final OrderMetricsType type;

  final String name;

  final String desc;

  final num current;

  final TextStyle? style;

  const _GoalItem({
    required this.type,
    required this.name,
    required this.desc,
    required this.current,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.value(20.0), //Analysis.instance.calculateGoal(type),
      builder: (context, snapshot) {
        final value = snapshot.hasData
            ? '／${(snapshot.data as num).prettyString()}'
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(name, style: style),
              const SizedBox(width: 4.0),
              InfoPopup(desc),
            ]),
            RichText(
                text: TextSpan(
              text: current.prettyString(),
              style: style,
              children: [
                if (value != null)
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            )),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }
}
