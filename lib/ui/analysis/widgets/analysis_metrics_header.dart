import 'package:flutter/material.dart';
import 'package:possystem/settings/currency_setting.dart';

class AnalysisMetricsHeader extends StatefulWidget {
  const AnalysisMetricsHeader({Key? key}) : super(key: key);

  @override
  State<AnalysisMetricsHeader> createState() => _AnalysisMetricsHeaderState();
}

class _AnalysisMetricsHeaderState extends State<AnalysisMetricsHeader> {
  @override
  Widget build(BuildContext context) {
    final headlineSmall = Theme.of(context).textTheme.headlineSmall;

    return Row(children: [
      buildEntry('銷售', 3000),
      Text('-', style: headlineSmall),
      buildEntry('成本', 1340),
      Text('=', style: headlineSmall),
      buildEntry('盈利', 1660),
    ]);
  }

  @override
  void initState() {
    super.initState();
  }

  Widget buildEntry(String label, num value) {
    return Expanded(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            value.toCurrency(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(label),
        ]),
      ),
    );
  }
}
