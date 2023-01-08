import 'package:flutter/material.dart';
import 'package:possystem/models/repository/seller.dart';

import 'widgets/analysis_order_list.dart';
import 'widgets/calendar_wrapper.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final orderListState = GlobalKey<AnalysisOrderListState<_OrderListParams>>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: OrientationBuilder(
        key: const Key('analysis.builder'),
        builder: (_, orientation) => orientation == Orientation.portrait
            ? _buildPortrait()
            : _buildLandscape(),
      ),
    );
  }

  Widget _buildCalendar({required bool isPortrait}) {
    return Tooltip(
      message: '上下滑動可以調整週期單位，如月或週。\n左右滑動調整週期。',
      child: CalendarWrapper(
        isPortrait: isPortrait,
        handleDaySelected: _handleDaySelected,
        searchCountInMonth: _searchCountInMonth,
      ),
    );
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

  Widget _buildOrderList() {
    return AnalysisOrderList<_OrderListParams>(
      key: orderListState,
      handleLoad: (_OrderListParams params, int offset) =>
          Seller.instance.getOrderBetween(params.start, params.end, offset),
    );
  }

  Widget _buildPortrait() {
    return Column(children: [
      _buildCalendar(isPortrait: true),
      Expanded(child: _buildOrderList()),
    ]);
  }

  void _handleDaySelected(DateTime day) async {
    final end = DateTime(day.year, day.month, day.day + 1);
    final start = DateTime(day.year, day.month, day.day);

    final result = await Seller.instance.getMetricBetween(start, end);

    orderListState.currentState?.reset(
      _OrderListParams(start: start, end: end),
      totalPrice: result['totalPrice'] as num,
      totalCount: result['count'] as int,
    );
  }

  Future<Map<DateTime, int>> _searchCountInMonth(DateTime day) {
    // add/sub 7 days for first/last few days on next/last month
    final end = DateTime(day.year, day.month + 1).add(const Duration(days: 7));
    final start =
        DateTime(day.year, day.month).subtract(const Duration(days: 7));

    return Seller.instance.getCountBetween(start, end);
  }
}

class _OrderListParams {
  final DateTime start;
  final DateTime end;

  const _OrderListParams({required this.start, required this.end});
}
