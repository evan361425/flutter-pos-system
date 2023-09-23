import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

int _hashDate(DateTime e) => e.day + e.month * 100 + e.year * 10000;
int _hashMonth(DateTime e) => e.month + e.year * 100;

class CalendarView extends StatefulWidget {
  final ValueNotifier<DateTimeRange> notifier;

  final Future<Map<DateTime, int>> Function(DateTime month) searchCountInMonth;

  final bool isPortrait;

  const CalendarView({
    Key? key,
    required this.notifier,
    required this.isPortrait,
    required this.searchCountInMonth,
  }) : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final List<int> _loadedMonths = <int>[];

  final LinkedHashMap<DateTime, int> _loadedCounts = LinkedHashMap(
    equals: isSameDay,
    hashCode: _hashDate,
  );

  CalendarFormat _calendarFormat = CalendarFormat.week;

  late DateTime _selectedDay;

  late DateTime _focusedDay;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // text being too large will cause overlay
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: TableCalendar<int>(
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
        // header
        // chinese will be hidden if using default value
        daysOfWeekHeight: 20.0,
        headerStyle: const HeaderStyle(formatButtonShowsNext: false),
        // show next format
        availableCalendarFormats: {
          CalendarFormat.month: S.analysisCalendarTwoWeek,
          CalendarFormat.twoWeeks: S.analysisCalendarWeek,
          CalendarFormat.week: S.analysisCalendarMonth,
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
        onPageChanged: _searchPageData,
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        onDaySelected: (DateTime selectedDay, DateTime focusedDay) =>
            _onDaySelected(selectedDay),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _focusedDay = _selectedDay = widget.notifier.value.start;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.watch<Seller>();
    _loadedMonths.clear();
    _loadedCounts.clear();
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

  /// the day is UTC!!!
  void _onDaySelected(DateTime day) {
    widget.notifier.value = Util.getDateRange(now: day.toLocal());
    setState(() {
      _selectedDay = _focusedDay = day;
    });
  }

  /// the [day] is UTC!!!
  void _searchPageData(DateTime day) {
    // make calender page stay in current page
    _focusedDay = day;
    final local = day.toLocal();
    if (!_loadedMonths.contains(_hashMonth(local))) {
      _searchCountInMonth(local);
    }
  }

  /// the [day] is UTC!!!
  void _searchCountInMonth(DateTime day) async {
    final local = day.toLocal();
    final counts = await widget.searchCountInMonth(local);

    if (mounted) {
      setState(() {
        _loadedMonths.add(_hashMonth(local));
        _loadedCounts.addAll(counts);
      });
    }
  }
}
