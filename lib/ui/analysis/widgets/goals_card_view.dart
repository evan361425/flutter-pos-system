import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/style/info_popup.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/analysis/ema_calculator.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/reloadable_card.dart';

class GoalsCardView extends StatefulWidget {
  /// Help to calculate the EMA of the last 20 days.
  final EMACalculator calculator;

  final Widget? action;

  const GoalsCardView({
    super.key,
    this.calculator = const EMACalculator(20),
    this.action,
  });

  @override
  State<GoalsCardView> createState() => _GoalsCardViewState();
}

class _GoalsCardViewState extends State<GoalsCardView> {
  OrderSummary? goal;

  final formatter = NumberFormat.percentPattern();

  @override
  Widget build(BuildContext context) {
    return ReloadableCard<OrderSummary>(
      id: 'goals',
      title: S.analysisGoalsTitle,
      notifiers: [Seller.instance],
      action: widget.action,
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
      goal = OrderSummary(at: DateTime(0));
    }

    super.initState();
  }

  Widget _builder(BuildContext context, OrderSummary metric) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(overflow: TextOverflow.ellipsis);

    return LayoutBuilder(builder: (context, constraint) {
      final compact = constraint.maxWidth < Breakpoint.compact.max;
      final align = goal!.profit == 0 ? MainAxisAlignment.start : MainAxisAlignment.spaceAround;
      return Row(mainAxisAlignment: align, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          _GoalItem(
            current: metric.count,
            goal: goal!.count,
            style: style,
            name: S.analysisGoalsCountTitle,
            desc: S.analysisGoalsCountDescription,
            compact: compact,
          ),
          _GoalItem(
            current: metric.revenue,
            goal: goal!.revenue,
            style: style,
            name: S.analysisGoalsRevenueTitle,
            desc: S.analysisGoalsRevenueDescription,
            compact: compact,
          ),
          _GoalItem(
            current: metric.profit,
            goal: goal!.profit,
            style: style,
            name: S.analysisGoalsProfitTitle,
            desc: S.analysisGoalsProfitDescription,
            compact: compact,
          ),
          _GoalItem(
            current: metric.cost,
            goal: 0,
            style: style,
            name: S.analysisGoalsCostTitle,
            compact: compact,
          ),
        ]),
        if (goal!.profit != 0)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Stack(children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: CircularProgressIndicator(
                    value: metric.profit / goal!.profit,
                    color: Colors.pink,
                    backgroundColor: Colors.grey.withAlpha(51),
                    strokeWidth: 20,
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      S.analysisGoalsAchievedRate(formatter.format(metric.profit / goal!.profit)),
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ]),
            ),
          ),
      ]);
    });
  }

  Future<OrderSummary> _loader() async {
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
      ignoreEmpty: true, // this will ignore today, so later we need to add it back.
      limit: goal == null ? widget.calculator.length + 1 : 1,
      orderDirection: "desc",
    );

    // Remove the first data, which is the latest data.
    final todayData = result.firstOrNull?.at == range.end.subtract(const Duration(days: 1))
        ? result.removeAt(0)
        : OrderSummary(at: range.start);

    if (goal == null) {
      final reversed = result.take(20).toList().reversed;
      goal = OrderSummary(
        at: DateTime(0), // this is dummy data, we don't need the date.
        values: {
          'count': widget.calculator.calculate(reversed.map((e) => e.count)),
          'revenue': widget.calculator.calculate(reversed.map((e) => e.revenue)),
          'profit': widget.calculator.calculate(reversed.map((e) => e.profit)),
        },
      );
    }

    return todayData;
  }
}

class _GoalItem extends StatelessWidget {
  final String name;

  final String? desc;

  final num current;

  final num goal;

  final TextStyle? style;

  final bool compact;

  const _GoalItem({
    required this.name,
    this.desc,
    required this.current,
    required this.goal,
    this.style,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final label = Row(children: [
      Text(name, style: style, overflow: TextOverflow.ellipsis),
      if (desc != null) InfoPopup(desc!),
    ]);
    final value = RichText(
      text: TextSpan(
        text: current.toCurrency(),
        style: style?.copyWith(fontSize: 24),
        children: goal != 0
            ? [
                TextSpan(
                  text: '／${goal.toCurrency()}',
                  style: const TextStyle(color: Colors.grey, fontSize: 24),
                ),
              ]
            : null,
      ),
    );

    if (compact) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        label,
        value,
        const SizedBox(height: 4),
      ]);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        label,
        const SizedBox(width: kInternalLargeSpacing),
        Expanded(child: Align(alignment: Alignment.centerRight, child: value)),
      ]),
    );
  }
}
