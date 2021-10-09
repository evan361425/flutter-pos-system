import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/calendar_wrapper.dart';
import 'package:possystem/ui/analysis/widgets/analysis_order_list.dart';
import 'package:provider/provider.dart';

class AnalysisScreen extends StatelessWidget {
  static final orderListState = GlobalKey<AnalysisOrderListState>();

  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tt('analysis.title')),
        leading: PopButton(),
      ),
      body: OrientationBuilder(
          builder: (_, orientation) => orientation == Orientation.portrait
              ? _buildPortrait()
              : _buildLandscape()),
    );
  }

  void handleDaySelected(DateTime day) {
    final end = DateTime(day.year, day.month, day.day + 1);
    final start = DateTime(day.year, day.month, day.day);

    Seller.instance.getMetricBetween(start, end).then((result) {
      orderListState.currentState?.reset(
        {'start': start, 'end': end},
        totalPrice: result['totalPrice'] as num,
        totalCount: result['count'] as int,
      );
    });
  }

  Future<List<OrderObject>> handleLoad(
    Map<String, Object> params,
    int offset,
  ) {
    return Seller.instance.getOrderBetween(
      params['start'] as DateTime,
      params['end'] as DateTime,
      offset,
    );
  }

  Widget _buildLandscape() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ChangeNotifierProvider.value(
            value: Seller.instance,
            child: CalendarWrapper(
              isPortrait: false,
              handleDaySelected: handleDaySelected,
              searchCountInMonth: _searchCountInMonth,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child:
                AnalysisOrderList(key: orderListState, handleLoad: handleLoad),
          ),
        ),
      ],
    );
  }

  Widget _buildPortrait() {
    return Column(children: [
      CalendarWrapper(
        isPortrait: true,
        handleDaySelected: handleDaySelected,
        searchCountInMonth: _searchCountInMonth,
      ),
      Expanded(
        child: AnalysisOrderList(key: orderListState, handleLoad: handleLoad),
      ),
    ]);
  }

  Future<Map<DateTime, int>> _searchCountInMonth(DateTime day) {
    // add/sub 7 days for first/last few days on next/last month
    final end = DateTime(day.year, day.month + 1).add(Duration(days: 7));
    final start = DateTime(day.year, day.month).subtract(Duration(days: 7));

    return Seller.instance.getCountBetween(start, end);
  }
}
