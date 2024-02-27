import 'package:flutter/material.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/helpers/analysis/ema_calculator.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/ui/analysis/widgets/reloadable_card.dart';

class GoalsCardView extends StatefulWidget {
  /// Help to calculate the EMA of the last 20 days.
  final EMACalculator calculator;

  const GoalsCardView({
    Key? key,
    this.calculator = const EMACalculator(20),
  }) : super(key: key);

  @override
  State<GoalsCardView> createState() => _GoalsCardViewState();
}

class _GoalsCardViewState extends State<GoalsCardView> {
  OrderDataPerDay? goal;

  @override
  Widget build(BuildContext context) {
    return ReloadableCard<OrderDataPerDay>(
      id: 'goals',
      title: '目標',
      notifier: Seller.instance,
      builder: _builder,
      loader: _loader,
    );
  }

  Widget _builder(BuildContext context, OrderDataPerDay metric) {
    final style = Theme.of(context).textTheme.bodyLarge;
    final goals = <Widget>[
      _GoalItem(
        type: OrderMetricType.count,
        current: metric.count,
        goal: goal!.count,
        style: style,
        name: '訂單數',
        desc:
            '訂單數反映了產品對顧客的吸引力。它代表了市場對你產品的需求程度，能幫助你了解何種產品或時段最受歡迎。高訂單數可能意味著你的定價策略或行銷活動取得成功，是商業模型有效性的指標之一。但要注意，單純追求高訂單數可能會忽略盈利能力。',
      ),
      _GoalItem(
        type: OrderMetricType.price,
        current: metric.price,
        goal: goal!.price,
        style: style,
        name: '營收',
        desc:
            '營收代表總銷售額，是業務規模的指標。高營收可能顯示了你的產品受歡迎且銷售良好，但營收無法反映出業務的可持續性和盈利能力。它不考慮成本和利潤，因此單純追求高營收可能會忽視實際利潤狀況。',
      ),
      _GoalItem(
        type: OrderMetricType.revenue,
        current: metric.revenue,
        goal: goal!.revenue,
        style: style,
        name: '盈利',
        desc:
            '盈利是店家能否持續經營的關鍵。盈利直接反映了營運效率和成本管理能力。不同於營收，盈利考慮了生意的開支，包括原料成本、人力、租金等，這是一個更實際的指標，能幫助你評估經營是否有效且可持續。即使有高營收，但如果成本高於營收，最終可能面臨經營困境。',
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('成本', style: style),
          Text(metric.cost.prettyString(), style: style),
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
        if (goal!.revenue != 0)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Stack(children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: CircularProgressIndicator(
                    value: metric.revenue / goal!.revenue,
                    color: Colors.pink,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    strokeWidth: 20,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '利潤達成\n${(metric.revenue / goal!.revenue * 100).prettyString()}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ]),
            ),
          ),
      ],
    );
  }

  Future<OrderDataPerDay> _loader() async {
    final range = Util.getDateRange();
    final result = await Seller.instance.getMetricsInPeriod(
      // If there is no data, we will calculate the EMA of the last 20 days.
      goal == null
          ? range.start.subtract(Duration(days: widget.calculator.length))
          : range.start,
      range.end,
      types: [
        OrderMetricType.count,
        OrderMetricType.price,
        OrderMetricType.revenue,
        OrderMetricType.cost,
      ],
      period: MetricsPeriod.day,
      ignoreEmpty: false,
    );

    // Remove the last data, which is the today's data.
    final last = result.removeLast();

    goal ??= OrderDataPerDay(
      at: range.end, // this is dummy data, we don't need the date.
      values: {
        'count':
            widget.calculator.calculate(result.map((e) => e.count)).toInt(),
        'price': widget.calculator.calculate(result.map((e) => e.price)),
        'revenue': widget.calculator.calculate(result.map((e) => e.revenue)),
      },
    );

    return last;
  }
}

class _GoalItem extends StatelessWidget {
  final OrderMetricType type;

  final String name;

  final String desc;

  final num current;

  final num goal;

  final TextStyle? style;

  const _GoalItem({
    required this.type,
    required this.name,
    required this.desc,
    required this.current,
    required this.goal,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
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
              TextSpan(
                text: '／${goal.prettyString()}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
