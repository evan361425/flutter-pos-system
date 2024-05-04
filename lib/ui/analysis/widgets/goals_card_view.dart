import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/helpers/analysis/ema_calculator.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/reloadable_card.dart';

class GoalsCardView extends StatefulWidget {
  /// Help to calculate the EMA of the last 20 days.
  final EMACalculator calculator;

  const GoalsCardView({
    super.key,
    this.calculator = const EMACalculator(20),
  });

  @override
  State<GoalsCardView> createState() => _GoalsCardViewState();
}

class _GoalsCardViewState extends State<GoalsCardView> {
  OrderDataPerDay? goal;

  final formatter = NumberFormat.percentPattern();

  @override
  Widget build(BuildContext context) {
    return ReloadableCard<OrderDataPerDay>(
      id: 'goals',
      title: S.analysisGoalsTitle,
      notifiers: [Seller.instance],
      builder: _builder,
      loader: _loader,
    );
  }

  @override
  void initState() {
    final enabled = Cache.instance.get<bool>('analysis.goals');
    // If the user disabled the goals, we don't need to load the data.
    // which is currently only option(goals is a beta feature).
    if (enabled != true) {
      goal = OrderDataPerDay(at: DateTime(0));
    }

    super.initState();
  }

  Widget _builder(BuildContext context, OrderDataPerDay metric) {
    final style = Theme.of(context).textTheme.bodyLarge;
    final goals = <Widget>[
      _GoalItem(
        type: OrderMetricType.count,
        current: metric.count,
        goal: goal!.count,
        style: style,
        name: S.analysisGoalsCountTitle,
        desc: S.analysisGoalsCountDescription,
      ),
      _GoalItem(
        type: OrderMetricType.revenue,
        current: metric.revenue,
        goal: goal!.revenue,
        style: style,
        name: S.analysisGoalsRevenueTitle,
        desc: S.analysisGoalsRevenueDescription,
      ),
      _GoalItem(
        type: OrderMetricType.profit,
        current: metric.revenue,
        goal: goal!.profit,
        style: style,
        name: S.analysisGoalsProfitTitle,
        desc: S.analysisGoalsProfitDescription,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.analysisGoalsCostTitle, style: style),
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
        if (goal!.profit != 0)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Stack(children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: CircularProgressIndicator(
                    value: metric.profit / goal!.profit,
                    color: Colors.pink,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    strokeWidth: 20,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      S.analysisGoalsAchievedRate(formatter.format(metric.profit / goal!.profit)),
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
      // If there is no data, we need to calculate the EMA from the last 20 data points withing 40 days.
      goal == null ? range.start.subtract(const Duration(days: 40)) : range.start,
      range.end,
      types: [
        OrderMetricType.count,
        OrderMetricType.revenue,
        OrderMetricType.profit,
        OrderMetricType.cost,
      ],
      ignoreEmpty: true,
      limit: widget.calculator.length + 1,
      orderDirection: "desc",
    );

    // Remove the first data, which is the today's data.
    final todayData = result.isEmpty ? OrderDataPerDay(at: range.start) : result.removeAt(0);

    final reversed = result.reversed;
    goal ??= OrderDataPerDay(
      at: DateTime(0), // this is dummy data, we don't need the date.
      values: {
        'count': widget.calculator.calculate(reversed.map((e) => e.count)),
        'revenue': widget.calculator.calculate(reversed.map((e) => e.revenue)),
        'profit': widget.calculator.calculate(reversed.map((e) => e.profit)),
      },
    );

    return todayData;
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
              if (goal != 0)
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
