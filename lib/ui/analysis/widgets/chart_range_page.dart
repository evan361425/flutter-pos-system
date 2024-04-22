import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/style/date_range_picker.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/translator.dart';

class ChartRangePage extends StatefulWidget {
  final DateTimeRange range;

  const ChartRangePage({super.key, required this.range});

  @override
  State<ChartRangePage> createState() => _ChartRangePageState();
}

class _ChartRangePageState extends State<ChartRangePage> with SingleTickerProviderStateMixin {
  late final TabController _controller;

  late DateTimeRange select;

  late final Map<_TabType, Map<String, DateTimeRange>> ranges;

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(MaterialLocalizations.of(context).unspecifiedDateRange),
        leading: const CloseButton(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(select),
            child: Text(local.okButtonLabel),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(controller: _controller, tabs: [
          for (final tab in _TabType.values) Tab(child: Text(S.analysisChartRangeTabName(tab.name), softWrap: true)),
        ]),
      ),
      body: TabBarView(controller: _controller, children: [
        for (final tab in [_TabType.day, _TabType.week, _TabType.month])
          ListView(
            children: [
              for (final e in ranges[tab]!.entries)
                RadioListTile(
                  title: Text(e.key),
                  subtitle: Text(e.value.format(S.localeName)),
                  value: e.value,
                  groupValue: select,
                  onChanged: (value) => setState(() => select = value!),
                ),
            ],
          ),
        ListView(
          children: [
            ListTile(
              title: Text(select.format(S.localeName)),
              onTap: () async {
                final value = await showMyDateRangePicker(context, select);

                if (value != null) {
                  setState(() => select = value);
                }
              },
            ),
          ],
        ),
      ]),
    );
  }

  @override
  void initState() {
    select = widget.range;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));
    final thisMonth = DateTime(today.year, today.month);
    ranges = {
      _TabType.day: {
        S.analysisChartRangeYesterday: DateTimeRange(
          start: today.subtract(const Duration(days: 1)),
          end: today,
        ),
        S.analysisChartRangeToday: DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        ),
      },
      _TabType.week: {
        S.analysisChartRangeLast7Days: DateTimeRange(
          start: today.subtract(const Duration(days: 7)),
          end: today,
        ),
        S.analysisChartRangeThisWeek: DateTimeRange(
          start: thisWeek,
          end: thisWeek.add(const Duration(days: 7)),
        ),
        S.analysisChartRangeLastWeek: DateTimeRange(
          start: thisWeek.subtract(const Duration(days: 7)),
          end: thisWeek,
        ),
      },
      _TabType.month: {
        S.analysisChartRangeLast30Days: DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: today,
        ),
        S.analysisChartRangeThisMonth: DateTimeRange(
          start: thisMonth,
          end: DateTime(now.year, now.month + 1),
        ),
        S.analysisChartRangeLastMonth: DateTimeRange(
          start: DateTime(now.year, now.month - 1),
          end: thisMonth,
        ),
      },
      _TabType.custom: {
        '': select,
      },
    };

    final tab = ranges.entries.firstWhereOrNull((e) => e.value.containsValue(select))?.key ?? _TabType.custom;
    _controller = TabController(length: 4, vsync: this, initialIndex: tab.index);

    super.initState();
  }
}

enum _TabType {
  day,
  week,
  month,
  custom;
}
