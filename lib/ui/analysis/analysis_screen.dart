import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/order_repo.dart';
import 'package:possystem/ui/analysis/widgets/calendar_wrapper.dart';
import 'package:possystem/ui/analysis/widgets/order_list.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  static final orderListState = GlobalKey<OrderListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('統計'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
      ),
      body: Column(children: [
        CalendarWrapper(
          handleDaySelected: _handleDaySelected,
          searchCountInMonth: _searchCountInMonth,
        ),
        Expanded(child: OrderList(key: orderListState)),
      ]),
    );
  }

  void _handleDaySelected(DateTime day) {
    final end = DateTime(day.year, day.month, day.day + 1);
    final start = DateTime(day.year, day.month, day.day);

    final future = OrderRepo.instance.getOrderBetween(start, end);

    orderListState.currentState!.load(future);
  }

  Future<Map<DateTime, int>> _searchCountInMonth(DateTime day) {
    final end = DateTime(day.year, day.month + 1);
    final start = DateTime(day.year, day.month);

    return OrderRepo.instance.getCountBetween(start, end);
  }
}
