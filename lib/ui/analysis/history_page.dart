import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/transit_station.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

import 'widgets/history_order_list.dart';
import 'widgets/calendar_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final ValueNotifier<DateTimeRange> notifier;

  @override
  Widget build(BuildContext context) {
    return TutorialWrapper(
      child: Scaffold(
        appBar: AppBar(
          leading: const PopButton(),
          title: const Text('訂單記錄'),
          actions: [
            Tutorial(
              id: 'history.export',
              title: '訂單資料匯出',
              message: '把訂單匯出到外部，讓你可以做進一步分析或保存。\n你可以到「設定」去匯出多日訂單。',
              spotlightBuilder: const SpotlightRectBuilder(borderRadius: 8.0),
              child: PopupMenuButton<TransitMethod>(
                key: const Key('history.export'),
                icon: const Icon(Icons.upload_file_sharp),
                tooltip: '匯出',
                itemBuilder: (context) => TransitMethod.values
                    .map((TransitMethod value) => PopupMenuItem<TransitMethod>(
                          value: value,
                          child: Text(S.transitMethod(value.name)),
                        ))
                    .toList(),
                onSelected: (value) {
                  context.pushNamed(Routes.transitStation, pathParameters: {
                    'method': value.name,
                    'type': 'order',
                  }, queryParameters: {
                    'range': serializeRange(notifier.value)
                  });
                },
              ),
            ),
          ],
        ),
        body: OrientationBuilder(
          builder: (context, orientation) => orientation == Orientation.portrait
              ? _buildPortrait()
              : _buildLandscape(),
        ),
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
      id: 'history.calendar',
      title: '日曆格式',
      message: '上下滑動可以調整週期單位，如月或週。\n左右滑動可以調整日期起訖。',
      spotlightBuilder: const SpotlightRectBuilder(),
      child: CalendarView(
        isPortrait: isPortrait,
        notifier: notifier,
      ),
    );
  }

  Widget _buildOrderList() {
    return HistoryOrderList(notifier: notifier);
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
}
