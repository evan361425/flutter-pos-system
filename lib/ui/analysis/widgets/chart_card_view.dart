import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/reloadable_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartCardView<T> extends StatefulWidget {
  final Chart<T> chart;

  const ChartCardView({
    super.key,
    required this.chart,
  });

  @override
  State<ChartCardView<T>> createState() => _ChartCardViewState<T>();
}

class _ChartCardViewState<T> extends State<ChartCardView<T>> {
  /// Range of the chart, it can updated by the user
  late ValueNotifier<DateTimeRange> range;

  @override
  Widget build(BuildContext context) {
    return ReloadableCard<List<T>>(
      id: widget.chart.name,
      wrappedByCard: false,
      notifier: range,
      builder: (context, metric) {
        return Column(children: [
          Row(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.chart.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            IconButton(
              key: Key('chart.${widget.chart.id}.reset'),
              onPressed: _resetRange,
              icon: const Icon(Icons.refresh_sharp),
            ),
            MoreButton(
              key: Key('chart.${widget.chart.id}.more'),
              onPressed: _showActions,
            ),
          ]),
          buildChart(context, metric),
          buildRangeSlider(),
        ]);
      },
      loader: () => widget.chart.loader(range.value.start, range.value.end),
    );
  }

  Widget buildChart(BuildContext context, List<T> metrics) {
    if (metrics.isEmpty) {
      return const SizedBox(
        width: 128,
        height: 128,
        child: Center(child: Text('沒有資料')),
      );
    }

    switch (widget.chart.type) {
      case AnalysisChartType.cartesian:
        return _CartesianChart(
          chart: widget.chart as CartesianChart,
          metrics: metrics as List<OrderDataPerDay>,
        );
      case AnalysisChartType.circular:
        return _CircularChart(
          chart: widget.chart as CircularChart,
          metrics: metrics as List<OrderMetricPerItem>,
        );
    }
  }

  Widget buildRangeSlider() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _updateRange(
              range.value.start.add(
                Duration(days: -widget.chart.range.duration.inDays),
              ),
            ),
            icon: const Icon(Icons.arrow_back_ios_new_sharp),
          ),
          Expanded(child: buildRangeText()),
          IconButton(
            onPressed: () => _updateRange(
              range.value.start.add(widget.chart.range.duration),
            ),
            icon: const Icon(Icons.arrow_forward_ios_sharp),
          ),
        ],
      ),
    );
  }

  Widget buildRangeText() {
    final f = DateFormat.MMMd(S.localeName);
    return OutlinedButton(
      key: Key('chart.${widget.chart.id}.range_button'),
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime(2021),
          lastDate: DateTime.now(),
          initialDate: range.value.start,
          helpText: '選擇日期範圍的開始',
        );

        if (date != null) {
          _updateRange(date);
        }
      },
      child:
          Text('${f.format(range.value.start)} – ${f.format(range.value.end)}'),
    );
  }

  @override
  void initState() {
    super.initState();

    range = ValueNotifier(DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now(),
    ));
    _resetRange();

    widget.chart.addListener(_resetRange);
  }

  @override
  void dispose() {
    widget.chart.removeListener(_resetRange);
    range.dispose();
    super.dispose();
  }

  void _resetRange() {
    final dur = widget.chart.range.duration;
    final newValue = Util.getDateRange(
      now: DateTime.now().subtract(dur),
      days: widget.chart.withToday ? dur.inDays + 1 : dur.inDays,
    );

    if (range.value != newValue) {
      range.value = newValue;
    } else {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      range.notifyListeners();
    }
  }

  void _updateRange(DateTime start) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (start == today || start.isAfter(today)) return;

    int days = widget.chart.range.duration.inDays;
    if (widget.chart.withToday &&
        Util.toUTC(now: start) ==
            Util.toUTC(now: today.subtract(widget.chart.range.duration))) {
      days = days + 1;
    }

    range.value = Util.getDateRange(
      now: start,
      days: days,
    );
  }

  void _showActions() async {
    await BottomSheetActions.withDelete<int>(
      context,
      deleteCallback: widget.chart.remove,
      deleteValue: 0,
      warningContent: Text(S.dialogDeletionContent(widget.chart.name, '')),
      actions: <BottomSheetAction<int>>[
        BottomSheetAction(
          title: const Text('編輯圖表'),
          leading: const Icon(KIcons.modal),
          route: Routes.chartOrderModal,
          routePathParameters: {'id': widget.chart.id},
        ),
      ],
    );
  }
}

class _CartesianChart extends StatelessWidget {
  final CartesianChart chart;

  final List<OrderDataPerDay> metrics;

  const _CartesianChart({
    required this.chart,
    required this.metrics,
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
          dateFormat: DateFormat(chart.range.period.format, S.localeName),
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
            return SplineSeries(
              animationDuration: 0,
              markerSettings: const MarkerSettings(isVisible: true),
              name: chart.target == OrderMetricTarget.order
                  ? S.analysisChartMetric(keyUnit.key)
                  : keyUnit.key,
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
  final CircularChart chart;

  final List<OrderMetricPerItem> metrics;

  const _CircularChart({
    required this.chart,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
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
          dataLabelMapper: (v, i) => '${v.percent.prettyString()}%',
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
