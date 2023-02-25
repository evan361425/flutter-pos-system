import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

int _hashDate(DateTime e) => e.day + e.month * 100 + e.year * 10000;
int _hashMonth(DateTime e) => e.month + e.year * 100;

class CalendarWrapper extends StatefulWidget {
  final Future<Map<DateTime, int>> Function(DateTime month) searchCountInMonth;

  final void Function(DateTime month) handleDaySelected;

  final bool isPortrait;

  /// default: DateTime.now()
  final DateTime? initialDate;

  const CalendarWrapper({
    Key? key,
    required this.searchCountInMonth,
    required this.handleDaySelected,
    required this.isPortrait,
    this.initialDate,
  }) : super(key: key);

  @override
  State<CalendarWrapper> createState() => _CalendarWrapperState();
}

class _CalendarWrapperState extends State<CalendarWrapper> {
  final List<int> _loadedMonths = <int>[];

  final LinkedHashMap<DateTime, int> _loadedCounts = LinkedHashMap(
    equals: isSameDay,
    hashCode: _hashDate,
  );

  CalendarFormat _calendarFormat = CalendarFormat.month;

  late DateTime _selectedDay;

  late DateTime _focusedDay;

  @override
  Widget build(BuildContext context) {
    return TableCalendar<int>(
      firstDay: DateTime(2021, 1),
      lastDay: DateTime.now(),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      shouldFillViewport: widget.isPortrait ? false : true,
      startingDayOfWeek: StartingDayOfWeek.monday,
      rangeSelectionMode: RangeSelectionMode.disabled,
      locale: SettingsProvider.instance
          .getSetting<LanguageSetting>()
          .value
          .toString(),
      // chinese will be hidden if using default value
      daysOfWeekHeight: 20.0,
      // header
      headerStyle: const HeaderStyle(formatButtonShowsNext: false),
      availableCalendarFormats: {
        CalendarFormat.month: S.analysisCalendarMonth,
        CalendarFormat.twoWeeks: S.analysisCalendarTwoWeek,
        CalendarFormat.week: S.analysisCalendarWeek,
      },
      // no need holiday/weekend days
      holidayPredicate: (day) => false,
      weekendDays: const [],
      // event handlers
      selectedDayPredicate: (DateTime day) => isSameDay(day, _selectedDay),
      eventLoader: (DateTime day) => List.filled(_loadedCounts[day] ?? 0, 0),
      calendarBuilders: CalendarBuilders(
        markerBuilder: _badgeBuilder,
        defaultBuilder: _defaultBuilder,
      ),
      onPageChanged: _handlePageChange,
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) =>
          _handleDaySelected(selectedDay),
    );
  }

  @override
  void initState() {
    super.initState();

    _focusedDay = _selectedDay = widget.initialDate ?? DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.watch<Seller>();
    _loadedMonths.clear();
    _loadedCounts.clear();
    widget.handleDaySelected(_selectedDay);
    _searchCountInMonth(_selectedDay);
  }

  Widget? _badgeBuilder(BuildContext context, DateTime day, List<int> value) {
    if (value.isEmpty) return null;

    final length = value.length;
    return Positioned(
      right: 0,
      top: 0,
      child: Badge(label: Text(length > 99 ? '99+' : length.toString())),
    );
  }

  Widget _defaultBuilder(
      BuildContext context, DateTime day, DateTime focusedDay) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.all(6.0),
      padding: EdgeInsets.zero,
      decoration: _loadedCounts.containsKey(day)
          ? const ShapeDecoration(
              shape: CircleBorder(side: BorderSide()),
            )
          : const BoxDecoration(shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text('${day.day}'),
    );
  }

  void _handleDaySelected(DateTime day) {
    widget.handleDaySelected(day);
    setState(() {
      _selectedDay = day;
      _focusedDay = day;
    });
  }

  void _handlePageChange(DateTime day) {
    // make calender page stay in current page
    _focusedDay = day;
    if (!_loadedMonths.contains(_hashMonth(day))) {
      _searchCountInMonth(day);
    }
  }

  void _searchCountInMonth(DateTime day) async {
    final counts = await widget.searchCountInMonth(day);

    setState(() {
      _loadedMonths.add(_hashMonth(day));
      _loadedCounts.addAll(counts);
    });
  }
}
