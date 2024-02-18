import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';

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
  OrderMetricTarget? target;
  final selection = <String>[];

  // ===== Cartesian properties =====
  final metrics = <OrderMetricType>[];

  // ===== Circular properties =====
  late TextEditingController _groupToController;

  @override
  String get title => widget.chart?.name ?? '新增圖表';

  @override
  List<Widget> buildFormFields() {
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
        title: const Text('是否忽略空資料'),
        subtitle: const Text('某商品或指標在時間內沒有資料，則不顯示。'),
      ),
      _buildWrappedChoices(
        '時間區間',
        '長時間可以看到趨勢，短時間可以看到變化。',
        OrderChartRange.values.map((e) {
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
        }),
      ),
      const TextDivider(label: '圖表類型'),
      p(SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 4.0,
          children: AnalysisChartType.values.map((e) {
            return ChoiceChip(
              key: Key('chart.type.${e.name}'),
              selected: type == e,
              label: Text(e.name),
              onSelected: (bool value) {
                setState(() {
                  type = e;
                });
              },
            );
          }).toList(),
        ),
      )),
      const TextDivider(label: '圖表資料'),
      if (type == AnalysisChartType.cartesian)
        _buildWrappedChoices(
          '觀看指標',
          '越多指標則圖表越難專注但是可以方便比較；\n和「項目種類」互斥，只能選擇一邊。',
          OrderMetricType.values.map((e) {
            return ChoiceChip(
              key: Key('chart.metrics.${e.name}'),
              selected: metrics.contains(e),
              label: Text(e.name),
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    metrics.add(e);
                    // intersect with target
                    target = null;
                  } else {
                    metrics.remove(e);
                  }
                });
              },
            );
          }),
        ),
      if (type == AnalysisChartType.circular)
        p(TextFormField(
          key: const Key('chart.groupTo'),
          controller: _groupToController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '最多顯示數',
            helperText: '顯示前幾名的項目，其餘歸類為「其他」；\n0 表示全部顯示。',
            filled: false,
          ),
          validator: Validator.positiveInt('最多顯示數'),
        )),
      _buildWrappedChoices(
        '項目種類',
        '選擇圖表中要出現哪些項目種類，一次只能選擇一種。',
        OrderMetricTarget.values.map((e) {
          return ChoiceChip(
            key: Key('chart.target.${e.name}'),
            selected: target == e,
            label: Text(e.name),
            onSelected: (bool value) {
              setState(() {
                if (value) {
                  target = e;
                  // intersect with metrics
                  metrics.clear();
                }
              });
            },
          );
        }),
      ),
      if (target != null)
        _buildWrappedChoices(
          '項目選擇',
          '你想要觀察哪些項目的變化，例如區間內某商品的訂單數。',
          _buildTargetItems(),
        ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildWrappedChoices(
    String label,
    String description,
    Iterable<ChoiceChip> chips,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 12.0),
      p(Text(label, style: textTheme.titleMedium)),
      p(Text(description, style: textTheme.labelMedium)),
      p(SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 4.0,
          // runSpacing: 4.0,
          children: chips.toList(),
        ),
      )),
    ]);
  }

  Iterable<ChoiceChip> _buildTargetItems() sync* {
    if (type != AnalysisChartType.circular ||
        target != OrderMetricTarget.attribute) {
      yield ChoiceChip(
        key: const Key('chart.item_all'),
        selected: selection.isEmpty,
        label: const Text('全選'),
        onSelected: (bool value) {
          setState(() {
            if (value) {
              selection.clear();
            }
          });
        },
      );
    }

    yield* _targetItems.map((e) => ChoiceChip(
          key: Key('chart.item.${e.id}'),
          selected: selection.contains(e.id),
          label: Text(e.name),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                // only one attribute can be selected in CircularChart
                if (type == AnalysisChartType.circular &&
                    target == OrderMetricTarget.attribute) {
                  selection.clear();
                }
                selection.add(e.id);
              } else {
                selection.remove(e.id);
              }
            });
          },
        ));
  }

  @override
  void initState() {
    type = widget.chart?.type ?? AnalysisChartType.cartesian;

    withToday = widget.chart?.withToday ?? false;
    ignoreEmpty = widget.chart?.ignoreEmpty ?? false;
    range = widget.chart?.range ?? OrderChartRange.sevenDays;

    _nameController = TextEditingController(text: widget.chart?.name);
    _groupToController = TextEditingController(text: '0');

    if (widget.chart == null) {
      metrics.addAll([OrderMetricType.price, OrderMetricType.revenue]);
      super.initState();
      return;
    }

    switch (type) {
      case AnalysisChartType.cartesian:
        final chart = widget.chart as CartesianChart;
        metrics.addAll(chart.metrics);
        target = chart.target;
        selection.addAll(chart.selection);
        break;
      case AnalysisChartType.circular:
        final chart = widget.chart as CircularChart;
        _groupToController.text = chart.groupTo.toString();
        target = chart.target;
        selection.addAll(chart.selection);
        break;
    }

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupToController.dispose();
    super.dispose();
  }

  Iterable<Model> get _targetItems {
    switch (target!) {
      case OrderMetricTarget.product:
        return Menu.instance.products;
      case OrderMetricTarget.catalog:
        return Menu.instance.itemList;
      case OrderMetricTarget.ingredient:
        return Stock.instance.items;
      case OrderMetricTarget.attribute:
        return OrderAttributes.instance.itemList;
    }
  }

  @override
  Future<void> updateItem() async {
    final model = type == AnalysisChartType.circular
        ? CircularChart.fromObject(CircularChartObject(
            name: _nameController.text,
            target: target,
            selection: selection,
            groupTo: int.parse(_groupToController.text),
            range: range,
            withToday: withToday,
            ignoreEmpty: ignoreEmpty,
          ))
        : CartesianChart.fromObject(CartesianChartObject(
            name: _nameController.text,
            metrics: metrics,
            target: target,
            selection: selection,
            range: range,
            withToday: withToday,
            ignoreEmpty: ignoreEmpty,
          ));

    if (widget.chart == null) {
      await Analysis.instance.addItem(model as Chart);
    } else {
      await widget.chart!.update(model.toObject());
    }

    if (mounted && context.canPop()) {
      context.pop();
    }
  }
}
