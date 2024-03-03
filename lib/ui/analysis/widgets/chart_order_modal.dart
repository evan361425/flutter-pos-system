import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartOrderModal extends StatefulWidget {
  final Chart? chart;

  const ChartOrderModal({super.key, required this.chart});

  @override
  State<ChartOrderModal> createState() => _ChartOrderModalState();
}

class _ChartOrderModalState extends State<ChartOrderModal>
    with ItemModal<ChartOrderModal> {
  final _nameController = TextEditingController();

  AnalysisChartType type = AnalysisChartType.cartesian;
  bool withToday = false;
  bool ignoreEmpty = true;
  OrderChartRange range = OrderChartRange.sevenDays;
  late OrderMetricTarget target;
  final metrics = <OrderMetricType>[];
  final targetItems = <String>[];

  @override
  String get title => widget.chart?.name ?? S.analysisChartCreate;

  @override
  List<Widget> buildFormFields() {
    return [
      p(TextFormField(
        key: const Key('chart.title'),
        controller: _nameController,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: S.analysisChartNameLabel,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit(S.analysisChartNameLabel, 16),
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
        title: Text(S.analysisChartWithTodayLabel),
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
        title: Text(S.analysisChartIgnoreEmptyLabel),
        subtitle: Text(S.analysisChartIgnoreEmptyHelper),
      ),
      _buildWrappedChoices(
        S.analysisChartRangeLabel,
        '${S.analysisChartRangeHelper}\n${S.singleChoice}',
        OrderChartRange.values.map((e) {
          return ChoiceChip(
            key: Key('chart.range.${e.name}'),
            selected: range == e,
            label: Text(S.analysisChartRange(e.name)),
            onSelected: (bool value) {
              if (value && range != e) {
                setState(() {
                  range = e;
                });
              }
            },
          );
        }),
      ),
      TextDivider(label: S.analysisChartTypeLabel),
      p(SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 4.0,
          children: AnalysisChartType.values.map((e) {
            return ChoiceChip(
              key: Key('chart.type.${e.name}'),
              selected: type == e,
              label: Text(S.analysisChartType(e.name)),
              onSelected: (bool value) {
                setState(() {
                  type = e;
                  _updateTarget(_allowedTargets.first);
                });
              },
            );
          }).toList(),
        ),
      )),
      _buildExampleChart(),
      TextDivider(label: S.analysisChartDataPropertiesDivider),
      _buildWrappedChoices(
        S.analysisChartTargetLabel,
        S.analysisChartTargetHelper,
        _allowedTargets.map((e) {
          return ChoiceChip(
            key: Key('chart.target.${e.name}'),
            selected: target == e,
            label: Text(S.analysisChartTarget(e.name)),
            onSelected: (bool value) {
              if (value && target != e) {
                setState(() {
                  _updateTarget(e);
                });
              }
            },
          );
        }),
      ),
      _buildWrappedChoices(
        S.analysisChartMetricLabel,
        '${S.analysisChartMetricHelper}\n${_singleMetric ? S.singleChoice : S.multiChoices}',
        _allowedMetrics.map((e) {
          return ChoiceChip(
            key: Key('chart.metrics.${e.name}'),
            selected: metrics.contains(e),
            label: Text(S.analysisChartMetric(e.name)),
            onSelected: (bool value) {
              setState(() {
                if (value) {
                  if (_singleMetric) metrics.clear();

                  metrics.add(e);
                } else if (metrics.length > 1) {
                  // Can't let metrics be empty
                  metrics.remove(e);
                }
              });
            },
          );
        }),
      ),
      if (_hasTargetItems)
        _buildWrappedChoices(
          S.analysisChartTargetItemLabel,
          '${S.analysisChartTargetItemHelper}\n${_singleTargetItem ? S.singleChoice : S.multiChoices}',
          _buildTargetItems(),
        ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildWrappedChoices(
    String label,
    String description,
    Iterable<Widget> chips,
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

  Iterable<Widget> _buildTargetItems() sync* {
    yield ChoiceChip(
      key: const Key('chart.item_all'),
      selected: targetItems.isEmpty,
      label: Text(S.analysisChartTargetItemSelectAll),
      onSelected: _singleTargetItem
          ? null
          : (bool value) {
              if (value) {
                setState(() {
                  targetItems.clear();
                });
              }
            },
    );

    yield const SizedBox(
      height: 44,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: VerticalDivider(),
      ),
    );

    yield* target.getItems().map((e) => ChoiceChip(
          key: Key('chart.item.${e.id}'),
          selected: targetItems.contains(e.name),
          label: Text(e.name),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                if (_singleTargetItem) targetItems.clear();

                targetItems.add(e.name);
              } else if (!_singleTargetItem) {
                targetItems.remove(e.name);
              }
            });
          },
        ));
  }

  Widget _buildExampleChart() {
    switch (type) {
      case AnalysisChartType.cartesian:
        return SfCartesianChart(
          plotAreaBorderWidth: 0.7,
          enableAxisAnimation: false,
          selectionGesture: ActivationMode.none,
          primaryXAxis: const NumericAxis(labelFormat: ' '),
          primaryYAxis: const NumericAxis(
            minimum: 0,
            maximum: 7,
            interval: 1,
            labelFormat: ' ',
          ),
          series: [
            SplineSeries<int, int>(
              xValueMapper: (_, i) => i,
              yValueMapper: (int data, _) => data,
              dataSource: const [3, 1, 4, 6, 5, 2, 5],
            ),
          ],
        );
      case AnalysisChartType.circular:
        return SfCircularChart(
          title: const ChartTitle(text: '範例'),
          selectionGesture: ActivationMode.none,
          series: <CircularSeries>[
            PieSeries<int, int>(
              dataSource: const [12, 34, 54],
              xValueMapper: (_, i) => i,
              yValueMapper: (int data, _) => data,
            ),
          ],
        );
    }
  }

  @override
  void initState() {
    super.initState();

    final chart = widget.chart;
    if (chart == null) {
      target = _allowedTargets.first;
      metrics.add(_allowedMetrics.first);
    } else {
      _nameController.text = chart.name;
      type = chart.type;
      withToday = chart.withToday;
      ignoreEmpty = chart.ignoreEmpty;
      range = chart.range;
      target = chart.target;
      metrics.addAll(chart.metrics);
      targetItems.addAll(chart.targetItems);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final object = ChartObject(
      name: _nameController.text,
      range: range,
      withToday: withToday,
      ignoreEmpty: ignoreEmpty,
      target: target,
      metrics: metrics,
      targetItems: targetItems.toSet().toList(),
    );
    final model = type == AnalysisChartType.circular
        ? CircularChart.fromObject(object)
        : CartesianChart.fromObject(object);

    if (widget.chart == null) {
      await Analysis.instance.addItem(model as Chart);
    } else {
      await widget.chart!.update(model.toObject());
    }

    if (mounted && context.canPop()) {
      context.pop();
    }
  }

  Iterable<OrderMetricTarget> get _allowedTargets {
    switch (type) {
      case AnalysisChartType.circular:
        return [
          OrderMetricTarget.catalog,
          OrderMetricTarget.product,
          OrderMetricTarget.ingredient,
          OrderMetricTarget.attribute,
        ];
      case AnalysisChartType.cartesian:
        return OrderMetricTarget.values;
    }
  }

  Iterable<OrderMetricType> get _allowedMetrics {
    switch (target) {
      case OrderMetricTarget.order:
      case OrderMetricTarget.catalog:
      case OrderMetricTarget.product:
        return OrderMetricType.values;
      default:
        return [
          OrderMetricType.count,
        ];
    }
  }

  bool get _singleMetric => target != OrderMetricTarget.order;

  bool get _singleTargetItem =>
      type == AnalysisChartType.circular &&
      target == OrderMetricTarget.attribute;

  bool get _hasTargetItems => target != OrderMetricTarget.order;

  void _updateTarget(OrderMetricTarget e) {
    target = e;
    metrics.clear();
    metrics.add(_allowedMetrics.first);
    targetItems.clear();

    if (_singleTargetItem) {
      targetItems.add(target.getItems().first.name);
    }
  }
}
