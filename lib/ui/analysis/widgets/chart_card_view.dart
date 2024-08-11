import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/reloadable_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartCardView extends StatelessWidget {
  final Chart chart;

  final ValueNotifier<DateTimeRange> range;

  const ChartCardView({
    super.key,
    required this.chart,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    return ReloadableCard<List>(
      id: chart.id,
      wrappedByCard: false,
      notifiers: [range, chart, Seller.instance],
      builder: (context, metric) {
        return Column(children: [
          Row(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  chart.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            _MoreButton(chart),
          ]),
          buildChart(context, metric),
        ]);
      },
      loader: () => chart.load(range.value),
    );
  }

  Widget buildChart(BuildContext context, List metrics) {
    if (metrics.isEmpty) {
      return SizedBox(
        width: 128,
        height: 128,
        child: Center(child: Text(S.analysisChartCardEmptyData)),
      );
    }

    switch (chart.type) {
      case AnalysisChartType.cartesian:
        return _CartesianChart(
          chart: chart,
          metrics: metrics as List<OrderSummary>,
          interval: MetricsIntervalType.fromDays(range.value.duration.inDays),
        );
      case AnalysisChartType.circular:
        return _CircularChart(
          chart: chart,
          metrics: metrics as List<OrderMetricPerItem>,
        );
    }
  }
}

class _CartesianChart extends StatelessWidget {
  final Chart chart;

  final List<OrderSummary> metrics;

  final MetricsIntervalType interval;

  const _CartesianChart({
    required this.chart,
    required this.metrics,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // catch drag event to prevent the parent from scrolling
      onHorizontalDragStart: (details) {},
      child: SfCartesianChart(
        plotAreaBorderWidth: 0.7,
        selectionType: SelectionType.point,
        selectionGesture: ActivationMode.singleTap,
        // get the different unit axis
        axes: chart.units
            .take(2)
            .mapIndexed((i, e) => NumericAxis(
                  opposedPosition: i == 1,
                  name: e.name,
                  labelFormat: e.labelFormat,
                ))
            .toList(),
        primaryXAxis: DateTimeAxis(
          enableAutoIntervalOnZooming: false,
          dateFormat: DateFormat(interval.format, S.localeName),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: const NumericAxis(isVisible: false),
        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          tooltipSettings: const InteractiveTooltip(
            format: 'series.name : point.y',
          ),
        ),
        legend: const Legend(
          isVisible: true,
        ),
        series: chart.keyUnits().map(
          (keyUnit) {
            return LineSeries(
              animationDuration: 0,
              markerSettings: const MarkerSettings(isVisible: true),
              name: chart.target == OrderMetricTarget.order ? S.analysisChartMetricName(keyUnit.key) : keyUnit.key,
              yAxisName: keyUnit.value.name,
              xValueMapper: (v, i) => v.at,
              yValueMapper: (v, i) => v.value(keyUnit.key),
              dataSource: metrics,
            );
          },
        ).toList(),
      ),
    );
  }
}

class _CircularChart extends StatelessWidget {
  final Chart chart;

  final List<OrderMetricPerItem> metrics;

  const _CircularChart({
    required this.chart,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    if (metrics.every((e) => e.value == 0)) {
      return SfCircularChart(
        tooltipBehavior: TooltipBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          animationDuration: 150,
          format: 'point.x : 0',
        ),
        legend: const Legend(isVisible: true),
        series: [
          PieSeries<OrderMetricPerItem, String>(
            animationDuration: 0,
            explode: false, // show larger section when tap
            name: chart.target.name,
            xValueMapper: (v, i) => v.name,
            yValueMapper: (v, i) => 1,
            dataSource: metrics,
            dataLabelMapper: (v, i) => '0%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.inside,
              overflowMode: OverflowMode.shift,
              labelIntersectAction: LabelIntersectAction.none,
            ),
          ),
        ],
      );
    }

    final percentFormat = NumberFormat.percentPattern(S.localeName);
    return SfCircularChart(
      tooltipBehavior: TooltipBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        animationDuration: 150,
        format: 'point.x : ${chart.units.first.tooltipFormat}',
      ),
      legend: const Legend(
        isVisible: true,
      ),
      series: [
        PieSeries<OrderMetricPerItem, String>(
          animationDuration: 0,
          explode: false, // show larger section when tap
          name: chart.target.name,
          xValueMapper: (v, i) => v.name,
          yValueMapper: (v, i) => v.value,
          dataSource: metrics,
          dataLabelMapper: (v, i) => percentFormat.format(v.percent),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
            overflowMode: OverflowMode.shift,
            labelIntersectAction: LabelIntersectAction.none,
          ),
        ),
      ],
    );
  }
}

// Separate the more button to correct showMenu position
class _MoreButton extends StatelessWidget {
  final Chart chart;

  const _MoreButton(this.chart);

  @override
  Widget build(BuildContext context) {
    return MoreButton(
      key: Key('chart.${chart.id}.more'),
      onPressed: _showActions,
    );
  }

  void _showActions(BuildContext context) async {
    await BottomSheetActions.withDelete<int>(
      context,
      deleteCallback: chart.remove,
      deleteValue: 0,
      warningContent: Text(S.dialogDeletionContent(chart.name, '')),
      actions: <BottomSheetAction<int>>[
        BottomSheetAction(
          title: Text(S.analysisChartCardTitleUpdate),
          leading: const Icon(KIcons.modal),
          route: Routes.chartUpdate,
          routePathParameters: {'id': chart.id},
        ),
      ],
    );
  }
}
