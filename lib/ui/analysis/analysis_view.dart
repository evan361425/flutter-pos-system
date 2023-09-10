import 'package:flutter/material.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

import 'widgets/analysis_order_list.dart';
import 'widgets/calendar_view.dart';

class AnalysisView extends StatefulWidget {
  final TutorialInTab? tab;

  const AnalysisView({Key? key, this.tab}) : super(key: key);

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  late final ValueNotifier<DateTimeRange> notifier;

  @override
  Widget build(BuildContext context) {
    return TutorialWrapper(
      tab: widget.tab,
      child: OrientationBuilder(
        key: const Key('analysis.builder'),
        builder: (context, orientation) => orientation == Orientation.portrait
            ? _buildPortrait()
            : _buildLandscape(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    notifier = ValueNotifier<DateTimeRange>(Util.getDateRange());
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  Widget _buildCalendar({required bool isPortrait}) {
    return Tutorial(
      id: 'analysis.calendar',
      title: '日曆格式',
      message: '上下滑動可以調整週期單位，如月或週。\n左右滑動可以調整日期起訖。',
      spotlightBuilder: const SpotlightRectBuilder(),
      child: CalendarView(
        isPortrait: isPortrait,
        notifier: notifier,
        searchCountInMonth: _searchCountInMonth,
      ),
    );
  }

  Widget _buildOrderList() {
    return AnalysisOrderList(notifier: notifier);
  }

  Widget _buildLandscape() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildCalendar(isPortrait: false)),
        Expanded(child: _buildOrderList()),
      ],
    );
  }

  Widget _buildPortrait() {
    return Column(children: [
      PhysicalModel(
        elevation: 5,
        color: Theme.of(context).colorScheme.background,
        shadowColor: Colors.transparent,
        child: _buildCalendar(isPortrait: true),
      ),
      Expanded(child: _buildOrderList()),
    ]);
  }

  Future<Map<DateTime, int>> _searchCountInMonth(DateTime day) {
    // add/sub 7 days for first/last few days on next/last month
    final end = DateTime(day.year, day.month + 1, 7);
    final start =
        DateTime(day.year, day.month).subtract(const Duration(days: 7));

    return Seller.instance.getCountBetween(start, end);
  }
}
