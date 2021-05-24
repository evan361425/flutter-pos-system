import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/services/cache.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/services/database.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  Locale _locale;

  final LinkedHashMap<DateTime, int> _orderCounts = LinkedHashMap(
    equals: isSameDay,
    hashCode: _hashDate,
  );
  final List<int> _loadedCounts = <int>[];

  List<OrderObject> _data;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets.all(5.0);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TableCalendar<Null>(
              firstDay: DateTime(2021, 1),
              focusedDay: _focusedDay,
              selectedDayPredicate: (DateTime day) =>
                  isSameDay(day, _selectedDay),
              lastDay: DateTime.now(),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              locale: _locale.toString(),
              rangeSelectionMode: RangeSelectionMode.disabled,
              eventLoader: (DateTime day) {
                return List.filled(_orderCounts[day] ?? 0, null);
              },
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                this.selectedDay = selectedDay;
              },
              onFormatChanged: (CalendarFormat selected) {
                if (_calendarFormat != selected) {
                  calendarFormat = selected;
                }
              },
              onPageChanged: _handlePageChange,
              calendarBuilders: CalendarBuilders(markerBuilder: _badgeBuilder),
            ),
            Expanded(child: _data == null ? CircularLoading() : _body(context))
          ],
        ),
      ),
    );
  }

  set selectedDay(DateTime day) {
    setState(() {
      _selectedDay = day;
      _filter();
    });
  }

  set calendarFormat(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
      Cache.instance.set<int>(Caches.analyze_calendar_format, format.index);
    });
  }

  Future<void> _handlePageChange(DateTime day) async {
    _focusedDay = day;
    if (!_loadedCounts.contains(_hashMonth(day))) {
      _loadedCounts.add(_hashMonth(day));
      await _getCounts(day);
    }
  }

  Widget _badgeBuilder(BuildContext context, DateTime day, List value) {
    if (value.isEmpty) return null;

    return Positioned(
      right: 0,
      bottom: 0,
      child: Material(
        shape: CircleBorder(side: BorderSide.none),
        // TODO: add to themes
        color: Colors.cyan,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(value.length.toString()),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    if (_data.isEmpty) {
      return Text('本日期無點餐紀錄', style: theme.textTheme.caption);
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_data[index].productNames.join(',')),
          onTap: () {},
        );
      },
      itemCount: _data.length,
    );
  }

  Future<void> _getCounts(DateTime day) async {
    final maxTime = DateTime(day.year, day.month + 1);
    final minTime = DateTime(day.year, day.month);

    final result = await Database.rawQuery(
      Tables.order,
      columns: ['COUNT(*) count', 'createdAt'],
      where: 'createdAt BETWEEN ? AND ?',
      groupBy: "STRFTIME('%m', createdAt,'unixepoch')",
      whereArgs: [
        minTime.millisecondsSinceEpoch ~/ 1000,
        maxTime.millisecondsSinceEpoch ~/ 1000,
      ],
    );

    setState(() {
      try {
        _orderCounts.addAll(<DateTime, int>{
          for (final row in result)
            DateTime.fromMillisecondsSinceEpoch(
                (row['createdAt'] as int) * 1000): row['count']
        });
      } catch (e) {
        print(e);
      }
    });
  }

  void _filter() {
    // final hour = _selectedTime?.hour ?? 23;
    // final minute = _selectedTime?.minute ?? 59;
    final maxTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day + 1,
    );
    final minTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    setState(() => _data = null);

    Database.query(
      Tables.order,
      where: 'createdAt BETWEEN ? AND ?',
      whereArgs: [
        minTime.millisecondsSinceEpoch ~/ 1000,
        maxTime.millisecondsSinceEpoch ~/ 1000,
      ],
      orderBy: 'createdAt desc',
    ).then((result) {
      setState(() {
        _data = result.map((row) => OrderObject.build(row)).toList();
      });
    }).catchError((err) => print(err));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Cache.instance.get<int>(Caches.analyze_calendar_format).then((value) {
      if (value != null && _calendarFormat.index != value) {
        setState(() => _calendarFormat = CalendarFormat.values[value]);
      }
    });

    final language = context.watch<LanguageProvider>();
    _locale = language.locale;
  }

  @override
  void initState() {
    super.initState();
    _filter();
    _handlePageChange(_selectedDay);
  }
}

int _hashDate(DateTime e) => e.day + e.month * 100 + e.year * 10000;
int _hashMonth(DateTime e) => e.month + e.year * 100;
