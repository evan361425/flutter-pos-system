import 'package:flutter/material.dart';
import 'package:possystem/components/scaffold/reorderable_scaffold.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/translator.dart';

class ChartReorder extends StatelessWidget {
  const ChartReorder({super.key});

  @override
  Widget build(BuildContext context) {
    return ReorderableScaffold(
      items: Analysis.instance.itemList,
      title: S.analysisChartTitleReorder,
      handleSubmit: (List<Chart> items) => Analysis.instance.reorderItems(items),
    );
  }
}
