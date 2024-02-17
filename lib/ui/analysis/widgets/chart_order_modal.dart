import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/repository/seller.dart';

class ChartOrderModal extends StatefulWidget {
  final Chart? chart;

  const ChartOrderModal({super.key, required this.chart});

  @override
  State<ChartOrderModal> createState() => _ChartOrderModalState();
}

class _ChartOrderModalState extends State<ChartOrderModal>
    with ItemModal<ChartOrderModal> {
  late AnalysisChartType type;

  late TextEditingController _nameController;
  late bool withToday;
  late bool ignoreEmpty;
  late OrderChartRange range;

  // ===== Cartesian properties =====
  final types = <OrderMetricsType>[];

  // ===== Circular properties =====

  @override
  String get title => widget.chart?.name ?? '新增圖表';

  @override
  List<Widget> buildFormFields() {
    final textTheme = Theme.of(context).textTheme;
    return [
      p(TextFormField(
        key: const Key('chart.title'),
        controller: _nameController,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: '標題',
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit('標題', 16),
      )),
      CheckboxListTile(
        key: const Key('chart.withToday'),
        controlAffinity: ListTileControlAffinity.leading,
        value: withToday,
        selected: withToday,
        onChanged: (bool? value) {
          setState(() {
            withToday = value!;
          });
        },
        title: const Text('資料是否包含今日'),
      ),
      CheckboxListTile(
        key: const Key('chart.ignoreEmpty'),
        controlAffinity: ListTileControlAffinity.leading,
        value: ignoreEmpty,
        selected: ignoreEmpty,
        onChanged: (bool? value) {
          setState(() {
            ignoreEmpty = value!;
          });
        },
        title: const Text('是否忽略沒有訂單的日期'),
        subtitle: const Text('例如七天內有一天沒有訂單，則只會有六天的資料'),
      ),
      if (type == AnalysisChartType.cartesian)
        ..._buildCartesianFields(textTheme),
      const TextDivider(label: '時間區間'),
      p(Center(
        child: Text(
          '長時間可以看到趨勢，短時間可以看到變化',
          style: textTheme.labelMedium,
        ),
      )),
      const SizedBox(height: 12.0),
      p(SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 4.0,
          // runSpacing: 4.0,
          children: OrderChartRange.values.map((e) {
            return ChoiceChip(
              key: Key('chart.range.${e.name}'),
              selected: range == e,
              label: Text(e.name),
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    range = e;
                  }
                });
              },
            );
          }).toList(),
        ),
      )),
    ];
  }

  Iterable<Widget> _buildCartesianFields(TextTheme textTheme) sync* {
    yield const TextDivider(label: '觀看指標');
    yield p(Center(
      child: Text(
        '圖表中要出現哪些指標，越多指標則圖表越難專注但是可以方便比較',
        style: textTheme.labelMedium,
      ),
    ));
    yield const SizedBox(height: 12.0);
    yield p(SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 4.0,
        // runSpacing: 4.0,
        children: OrderMetricsType.values.map((e) {
          return ChoiceChip(
            key: Key('chart.type.${e.name}'),
            selected: types.contains(e),
            label: Text(e.name),
            onSelected: (bool value) {
              setState(() {
                if (value) {
                  types.add(e);
                } else {
                  types.remove(e);
                }
              });
            },
          );
        }).toList(),
      ),
    ));
  }

  @override
  void initState() {
    type = widget.chart?.type ?? AnalysisChartType.cartesian;

    _nameController = TextEditingController(text: widget.chart?.name);
    withToday = widget.chart?.withToday ?? false;
    ignoreEmpty = widget.chart?.ignoreEmpty ?? false;
    range = widget.chart?.range ?? OrderChartRange.sevenDays;

    if (widget.chart == null) {
      types.addAll(OrderMetricsType.values);
    } else {
      switch (type) {
        case AnalysisChartType.cartesian:
          types.addAll((widget.chart as CartesianChart).types);
          break;
        case AnalysisChartType.circular:
          break;
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final object = CartesianChartObject(
      name: _nameController.text,
      withToday: withToday,
      ignoreEmpty: ignoreEmpty,
      range: range,
      types: types,
    );

    if (widget.chart == null) {
      await Analysis.instance.addItem(CartesianChart.fromObject(object));
    } else {
      await widget.chart!.update(object);
    }

    if (mounted && context.canPop()) {
      context.pop();
    }
  }
}
