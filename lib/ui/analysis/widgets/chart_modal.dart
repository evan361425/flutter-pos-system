import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/analysis/chart_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartModal extends StatefulWidget {
  final Chart? chart;

  const ChartModal({super.key, this.chart});

  @override
  State<ChartModal> createState() => _ChartModalState();
}

class _ChartModalState extends State<ChartModal> with ItemModal<ChartModal> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  AnalysisChartType type = AnalysisChartType.cartesian;
  bool ignoreEmpty = false;
  late OrderMetricTarget target;
  final metrics = <OrderMetricType>[];
  final targetItems = <String>[];

  @override
  String get title => widget.chart == null ? S.analysisChartTitleCreate : S.analysisChartTitleUpdate;

  @override
  List<Widget> buildFormFields() {
    return [
      p(TextFormField(
        key: const Key('chart.title'),
        controller: _nameController,
        focusNode: _nameFocusNode,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: S.analysisChartModalNameLabel,
          hintText: widget.chart?.name,
          filled: false,
        ),
        maxLength: 50,
        validator: Validator.textLimit(
          S.analysisChartModalNameLabel,
          50,
          focusNode: _nameFocusNode,
        ),
      )),
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
        title: Text(S.analysisChartModalIgnoreEmptyLabel),
        subtitle: Text(S.analysisChartModalIgnoreEmptyHelper),
      ),
      TextDivider(label: S.analysisChartModalTypeLabel),
      p(SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 4.0,
          children: AnalysisChartType.values.map((e) {
            return ChoiceChip(
              key: Key('chart.type.${e.name}'),
              selected: type == e,
              label: Text(S.analysisChartModalTypeName(e.name)),
              onSelected: (bool value) {
                type = e;
                _updateTarget(_allowedTargets.first);
                setState(() {
                  _updateTargetItem(_allowedTargets.first);
                });
              },
            );
          }).toList(),
        ),
      )),
      _buildExampleChart(),
      TextDivider(label: S.analysisChartModalDivider),
      _buildWrappedChoices(
        S.analysisChartModalTargetLabel,
        S.analysisChartModalTargetHelper,
        _allowedTargets.map((e) {
          return ChoiceChip(
            key: Key('chart.target.${e.name}'),
            selected: target == e,
            label: Text(S.analysisChartTargetName(e.name)),
            onSelected: (bool value) {
              if (value && target != e) {
                _updateTarget(e);
                setState(() {
                  _updateTargetItem(e);
                });
              }
            },
          );
        }),
      ),
      _buildWrappedChoices(
        S.analysisChartModalMetricLabel,
        '${S.analysisChartModalMetricHelper}\n${_singleMetric ? S.singleChoice : S.multiChoices}',
        _allowedMetrics.map((e) {
          return ChoiceChip(
            key: Key('chart.metrics.${e.name}'),
            selected: metrics.contains(e),
            label: Text(S.analysisChartMetricName(e.name)),
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
          S.analysisChartModalTargetItemLabel,
          '${S.analysisChartModalTargetItemHelper}\n${_singleTargetItem ? S.singleChoice : S.multiChoices}',
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
      label: Text(S.analysisChartModalTargetItemSelectAll),
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
            LineSeries<int, int>(
              xValueMapper: (_, i) => i,
              yValueMapper: (int data, _) => data,
              dataSource: const [3, 1, 4, 6, 5, 2, 5],
            ),
          ],
        );
      case AnalysisChartType.circular:
        return SfCircularChart(
          title: const ChartTitle(),
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
      ignoreEmpty = chart.ignoreEmpty;
      target = chart.target;
      metrics.addAll(chart.metrics);
      targetItems.addAll(chart.targetItems);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    final model = Chart.fromObject(ChartObject(
      name: _nameController.text,
      type: type,
      ignoreEmpty: ignoreEmpty,
      target: target,
      metrics: metrics,
      targetItems: targetItems.toSet().toList(),
    ));

    if (widget.chart == null) {
      await Analysis.instance.addItem(model);
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

  bool get _singleTargetItem => type == AnalysisChartType.circular && target == OrderMetricTarget.attribute;

  bool get _hasTargetItems => target != OrderMetricTarget.order;

  void _updateTarget(OrderMetricTarget e) {
    target = e;
    metrics.clear();
    metrics.add(_allowedMetrics.first);
  }

  /// separate from [_updateTarget] to avoid check-mark dynamically change the ChoiceChip width
  void _updateTargetItem(OrderMetricTarget e) {
    targetItems.clear();
    if (_singleTargetItem) {
      targetItems.add(e.getItems().first.name);
    }
  }
}
