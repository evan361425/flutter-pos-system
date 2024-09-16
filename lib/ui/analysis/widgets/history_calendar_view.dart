import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

int _hashDate(DateTime e) => e.day + e.month * 100 + e.year * 10000;
int _hashMonth(DateTime e) => e.month + e.year * 100;

class HistoryCalendarView extends StatefulWidget {
  final ValueNotifier<DateTimeRange> notifier;

  final bool shouldFillViewport;

  const HistoryCalendarView({
    super.key,
    required this.notifier,
    required this.shouldFillViewport,
  });

  @override
  State<HistoryCalendarView> createState() => _HistoryCalendarViewState();
}

class _HistoryCalendarViewState extends State<HistoryCalendarView> {
  final List<int> _loadedMonths = <int>[];

  final LinkedHashMap<DateTime, int> _loadedCounts = LinkedHashMap(
    equals: isSameDay,
    hashCode: _hashDate,
  );

  late CalendarFormat _calendarFormat;

  late DateTime _selectedDay;

  late DateTime _focusedDay;

  @override
  Widget build(BuildContext context) {
    // text being too large will cause overlay
    return MediaQuery.withNoTextScaling(
      child: TableCalendar<void>(
        firstDay: DateTime(2021, 1),
        lastDay: DateTime.now(),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        shouldFillViewport: widget.shouldFillViewport,
        startingDayOfWeek: StartingDayOfWeek.monday,
        rangeSelectionMode: RangeSelectionMode.disabled,
        locale: LanguageSetting.instance.language.locale.toString(),
        // header
        // chinese will be hidden if using default value
        daysOfWeekHeight: 20.0,
        headerStyle: const HeaderStyle(formatButtonShowsNext: false),
        // show next format, so k/v are not matching
        availableCalendarFormats: {
          CalendarFormat.month: S.twoWeeks,
          CalendarFormat.twoWeeks: S.singleWeek,
          CalendarFormat.week: S.singleMonth,
        },
        // no need holiday/weekend days
        holidayPredicate: (day) => false,
        weekendDays: const [],
        // event handlers
        selectedDayPredicate: (DateTime day) => isSameDay(day, _selectedDay),
        eventLoader: (DateTime day) => List.filled(_loadedCounts[day] ?? 0, null),
        calendarBuilders: CalendarBuilders(
          markerBuilder: _badgeBuilder,
          defaultBuilder: _defaultBuilder,
        ),
        onPageChanged: _searchPageData,
        onFormatChanged: (format) async {
          setState(() => _calendarFormat = format);
          await Cache.instance.set('history.calendar_format', format.index);
        },
        onDaySelected: (DateTime selectedDay, DateTime focusedDay) => _onDaySelected(selectedDay),
      ),
    );
  }

  @override
  void initState() {
    _focusedDay = _selectedDay = widget.notifier.value.start;

    // cache from last time, or default to month if in wide screen else week
    final cached = Cache.instance.get<int>('history.calendar_format') ?? CalendarFormat.values.length;
    _calendarFormat = CalendarFormat.values.elementAtOrNull(cached) ??
        (widget.shouldFillViewport ? CalendarFormat.month : CalendarFormat.week);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.watch<Seller>();
    _loadedMonths.clear();
    _loadedCounts.clear();
    _searchCountInMonth(_selectedDay);
  }

  Widget? _badgeBuilder(BuildContext context, DateTime day, List<void> value) {
    if (value.isEmpty) return null;

    final length = value.length;
    return Positioned(
      right: 0,
      top: 0,
      child: Badge(label: Text(length > 99 ? '99+' : length.toString())),
    );
  }

  Widget _defaultBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    final local = day.toLocal();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.all(6.0),
      padding: EdgeInsets.zero,
      decoration: _loadedCounts.containsKey(local)
          ? const ShapeDecoration(
              shape: CircleBorder(side: BorderSide()),
            )
          : const BoxDecoration(shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text('${local.day}'),
    );
  }

  /// the day is UTC formatted
  void _onDaySelected(DateTime day) {
    widget.notifier.value = Util.getDateRange(now: day.toLocal());
    setState(() {
      _selectedDay = _focusedDay = day;
    });
  }

  /// the [day] is UTC formatted
  void _searchPageData(DateTime day) {
    // make calender page stay in current page
    _focusedDay = day;
    final local = day.toLocal();
    if (!_loadedMonths.contains(_hashMonth(local))) {
      _searchCountInMonth(local);
    }
  }

  /// the [day] is UTC formatted
  void _searchCountInMonth(DateTime day) async {
    final local = day.toLocal();
    // add/sub 7 days for first/last few days on next/last month
    final end = DateTime(local.year, local.month + 1, 7);
    final start = DateTime(local.year, local.month).subtract(const Duration(days: 7));

    final metrics = await Seller.instance.getMetricsInPeriod(
      start,
      end,
      types: [OrderMetricType.count],
    );

    if (mounted) {
      setState(() {
        _loadedMonths.add(_hashMonth(local));
        _loadedCounts.addAll({
          for (final m in metrics) m.at: m.count,
        });
      });
    }
  }
}
