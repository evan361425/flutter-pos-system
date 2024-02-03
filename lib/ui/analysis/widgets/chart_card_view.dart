import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/analysis/chart.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/reloadable_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartCardView extends StatefulWidget {
  final Chart chart;

  const ChartCardView({Key? key, required this.chart}) : super(key: key);

  @override
  State<ChartCardView> createState() => _ChartCardViewState();
}

class _ChartCardViewState extends State<ChartCardView> {
  /// Trackball behavior, used to show tooltip
  final _trackballBehavior = TrackballBehavior(
    enable: true,
    activationMode: ActivationMode.singleTap,
    tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
    tooltipSettings: const InteractiveTooltip(
      format: 'series.name : point.y',
    ),
  );

  /// Range of the chart, it can updated by the user
  late ValueNotifier<DateTimeRange> range;

  @override
  Widget build(BuildContext context) {
    return ReloadableCard<List<OrderMetricPerDay>>(
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
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            IconButton(
              onPressed: _resetRange,
              icon: const Icon(Icons.refresh_sharp),
            ),
            MoreButton(onPressed: _showActions),
          ]),
          buildChart(context, metric),
          buildRangeSlider(),
        ]);
      },
      loader: () {
        return Seller.instance.getMetricsInPeriod(
          range.value.start,
          range.value.end,
          types: widget.chart.types,
          period: widget.chart.range.period,
          fulfillAll: !widget.chart.ignoreEmpty,
        );
      },
    );
  }

  Widget buildChart(BuildContext context, List<OrderMetricPerDay> metrics) {
    if (metrics.isEmpty) {
      return const Center(child: Text('沒有資料'));
    }

    return SfCartesianChart(
      plotAreaBorderWidth: 0.7,
      selectionType: SelectionType.point,
      selectionGesture: ActivationMode.singleTap,
      primaryXAxis: DateTimeAxis(
        enableAutoIntervalOnZooming: false,
        dateFormat: DateFormat(widget.chart.range.period.format, S.localeName),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        labelFormat: widget.chart.types.first.label,
      ),
      trackballBehavior: _trackballBehavior,
      legend: const Legend(
        isVisible: true,
      ),
      series: widget.chart.types
          .mapIndexed(
            (i, e) => LineSeries(
              markerSettings: const MarkerSettings(isVisible: true),
              name: e.title,
              xValueMapper: (v, i) => v.at,
              yValueMapper: (v, i) => v.valueFromType(e),
              dataSource: metrics,
            ),
          )
          .toList(),
    );
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
    range.value = Util.getDateRange(
      now: DateTime.now().subtract(dur),
      days: widget.chart.withToday ? dur.inDays + 1 : dur.inDays,
    );
  }

  void _updateRange(DateTime start) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (start.isAfter(today)) return;

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
