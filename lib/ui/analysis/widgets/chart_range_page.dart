import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/translator.dart';

class ChartRangePage extends StatefulWidget {
  final DateTimeRange range;

  const ChartRangePage({super.key, required this.range});

  @override
  State<ChartRangePage> createState() => _ChartRangePageState();
}

class _ChartRangePageState extends State<ChartRangePage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  late DateTimeRange select;

  late final Map<_TabType, Map<String, DateTimeRange>> ranges;

  final format = DateFormat.MMMd(S.localeName);

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
          for (final tab in _TabType.values)
            Tab(child: Text(tab.title, softWrap: true)),
        ]),
      ),
      body: TabBarView(controller: _controller, children: [
        for (final tab in [_TabType.date, _TabType.week, _TabType.month])
          ListView(
            children: [
              for (final e in ranges[tab]!.entries)
                RadioListTile(
                  title: Text(e.key),
                  subtitle: Text(e.value.format(format)),
                  value: e.value,
                  groupValue: select,
                  onChanged: (value) => setState(() => select = value!),
                ),
            ],
          ),
        ListView(
          children: [
            ListTile(
              title: Text(select.format(format)),
              onTap: () async {
                final value = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2021),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(
                    start: select.start,
                    end: select.end.subtract(const Duration(days: 1)),
                  ),
                );
                if (value != null) {
                  setState(() => select = DateTimeRange(
                        start: value.start,
                        end: value.end.add(const Duration(days: 1)),
                      ));
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
      _TabType.date: {
        '昨日': DateTimeRange(
          start: today.subtract(const Duration(days: 1)),
          end: today,
        ),
        '今日': DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        ),
      },
      _TabType.week: {
        '最近7日': DateTimeRange(
          start: today.subtract(const Duration(days: 7)),
          end: today,
        ),
        '本週': DateTimeRange(
          start: thisWeek,
          end: thisWeek.add(const Duration(days: 7)),
        ),
        '上週': DateTimeRange(
          start: thisWeek.subtract(const Duration(days: 7)),
          end: thisWeek,
        ),
      },
      _TabType.month: {
        '最近30日': DateTimeRange(
          start: today.subtract(const Duration(days: 30)),
          end: today,
        ),
        '本月': DateTimeRange(
          start: thisMonth,
          end: DateTime(now.year, now.month + 1),
        ),
        '上月': DateTimeRange(
          start: DateTime(now.year, now.month - 1),
          end: thisMonth,
        ),
      },
      _TabType.custom: {
        '': select,
      },
    };

    final tab = ranges.entries
            .firstWhereOrNull((e) => e.value.containsValue(select))
            ?.key ??
        _TabType.custom;
    _controller =
        TabController(length: 4, vsync: this, initialIndex: tab.index);

    super.initState();
  }
}

enum _TabType {
  date('日期'),
  week('週'),
  month('月'),
  custom('自訂');

  final String title;

  const _TabType(this.title);
}
