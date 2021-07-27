import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:possystem/providers/language_provider.dart';
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

  CalendarWrapper({
    Key? key,
    required this.searchCountInMonth,
    required this.handleDaySelected,
    required this.isPortrait,
    this.initialDate,
  }) : super(key: key);

  @override
  _CalendarWrapperState createState() => _CalendarWrapperState();
}

class _CalendarWrapperState extends State<CalendarWrapper> {
  late Locale _locale;

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
    return TableCalendar<Null>(
      firstDay: DateTime(2021, 1),
      lastDay: DateTime.now(),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      shouldFillViewport: widget.isPortrait ? false : true,
      startingDayOfWeek: StartingDayOfWeek.monday,
      rangeSelectionMode: RangeSelectionMode.disabled,
      locale: _locale.toString(),
      // header
      headerStyle: HeaderStyle(formatButtonShowsNext: false),
      availableCalendarFormats: {
        CalendarFormat.month: tt('analysis.calendar.month'),
        CalendarFormat.twoWeeks: tt('analysis.calendar.twoWeeks'),
        CalendarFormat.week: tt('analysis.calendar.week'),
      },
      // no need holiday/weekend days
      holidayPredicate: (day) => false,
      weekendDays: const [],
      // event handlers
      selectedDayPredicate: (DateTime day) => isSameDay(day, _selectedDay),
      eventLoader: (DateTime day) => List.filled(_loadedCounts[day] ?? 0, null),
      calendarBuilders: CalendarBuilders(markerBuilder: _badgeBuilder),
      onPageChanged: _handlePageChange,
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      onDaySelected: (DateTime selectedDay, DateTime focusedDay) =>
          _handleDaySelected(selectedDay),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _locale = context.watch<LanguageProvider>().locale;
  }

  @override
  void initState() {
    super.initState();

    _focusedDay = _selectedDay = widget.initialDate ?? DateTime.now();

    widget.searchCountInMonth(_selectedDay).then((counts) {
      _loadedMonths.add(_hashMonth(_selectedDay));
      setState(() => _loadedCounts.addAll(counts));
    });
  }

  Widget? _badgeBuilder(BuildContext context, DateTime day, List<Null> value) {
    if (value.isEmpty) return null;

    final length = value.length;
    final theme = Theme.of(context);
    final fontColor = theme.colorScheme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;

    return Positioned(
      right: 0,
      bottom: 0,
      child: Material(
        shape: CircleBorder(side: BorderSide.none),
        color: theme.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            length > 99 ? '99+' : length.toString(),
            style: TextStyle(fontSize: 12.0, color: fontColor),
          ),
        ),
      ),
    );
  }

  void _handleDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
      _focusedDay = day;

      if (widget.isPortrait) {
        _calendarFormat = CalendarFormat.week;
      }

      widget.handleDaySelected(day);
    });
  }

  Future<void> _handlePageChange(DateTime day) async {
    // make calander page stay in current page
    _focusedDay = day;

    final month = _hashMonth(day);
    if (!_loadedMonths.contains(month)) {
      setState(() => _calendarFormat = CalendarFormat.month);
      _loadedMonths.add(month);

      final counts = await widget.searchCountInMonth(day);

      setState(() => _loadedCounts.addAll(counts));
    }
  }
}
