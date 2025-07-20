import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/history_actions.dart';
import 'package:possystem/ui/transit/transit_station.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

import 'widgets/history_calendar_view.dart';
import 'widgets/history_order_list.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final ValueNotifier<DateTimeRange> notifier;

  @override
  Widget build(BuildContext context) {
    final singleView = MediaQuery.sizeOf(context).width <= Breakpoint.medium.max;
    return TutorialWrapper(
      child: Scaffold(
        appBar: AppBar(
          leading: const PopButton(),
          title: Text(S.analysisHistoryTitle),
          actions: [
            Tutorial(
              id: 'history.action',
              title: S.analysisHistoryActionTutorialTitle,
              message: S.analysisHistoryActionTutorialContent,
              spotlightBuilder: const SpotlightRectBuilder(borderRadius: 8.0),
              child: MenuAnchor(
                builder: (context, controller, child) => IconButton(
                  key: const Key('history.action'),
                  onPressed: controller.open,
                  icon: const Icon(KIcons.more),
                ),
                menuChildren: [
                  SubmenuButton(
                    key: const Key('history.action.export'),
                    menuChildren: TransitMethod.values
                        .map((e) => MenuItemButton(
                              onPressed: () => _onExport(e),
                              child: Text(e.l10nName),
                            ))
                        .toList(),
                    child: Text(S.analysisHistoryActionExport),
                  ),
                  MenuItemButton(
                    key: const Key('history.action.clear'),
                    onPressed: _onClear,
                    child: Text(S.analysisHistoryActionClear),
                  ),
                  MenuItemButton(
                    key: const Key('history.action.reset_no'),
                    onPressed: _onResetNo,
                    child: Text(S.analysisHistoryActionResetNo),
                  ),
                  MenuItemButton(
                    key: const Key('history.action.schedule_reset_no'),
                    onPressed: _onScheduleResetNo,
                    child: Text(S.analysisHistoryActionScheduleResetNo),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: singleView ? _buildSingleColumn() : _buildTwoColumns(),
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

  Widget _buildTwoColumns() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildCalendar(shouldFillViewport: true)),
        Expanded(child: _buildOrderList()),
      ],
    );
  }

  Widget _buildSingleColumn() {
    return Column(children: [
      PhysicalModel(
        elevation: 5,
        color: Theme.of(context).colorScheme.surface,
        shadowColor: Colors.transparent,
        child: _buildCalendar(shouldFillViewport: false),
      ),
      Expanded(child: _buildOrderList()),
    ]);
  }

  Widget _buildCalendar({required bool shouldFillViewport}) {
    return Tutorial(
      id: 'history.calendar',
      title: S.analysisHistoryCalendarTutorialTitle,
      message: S.analysisHistoryCalendarTutorialContent,
      spotlightBuilder: const SpotlightRectBuilder(),
      child: HistoryCalendarView(
        shouldFillViewport: shouldFillViewport,
        notifier: notifier,
      ),
    );
  }

  Widget _buildOrderList() {
    return HistoryOrderList(notifier: notifier);
  }

  void _onExport(TransitMethod method) async {
    await context.pushNamed(
      Routes.transitStation,
      pathParameters: {'method': method.name, 'catalog': 'order'},
      queryParameters: {'range': serializeRange(notifier.value)},
    );
  }

  void _onClear() async {
    final dateTime = await HistoryCleanDialog.show(context);
    if (dateTime != null && context.mounted) {
      await Seller.instance.clear(dateTime);
      // ignore: use_build_context_synchronously
      showSnackBar(S.actSuccess, context: context);
    }
  }

  void _onResetNo() async {
    final ok = await ConfirmDialog.show(
      context,
      title: S.analysisHistoryActionResetNo,
      content: S.analysisHistoryActionResetNoHint,
    );
    if (ok) {
      await Seller.instance.resetId();
      // ignore: use_build_context_synchronously
      showSnackBar(S.actSuccess, context: context);
    }
  }

  void _onScheduleResetNo() async {
    final period = await HistoryScheduleResetNoDialog.show(context);
    if (period != null && context.mounted) {
      await Seller.instance.updateResetIdPeriod(period);
      // ignore: use_build_context_synchronously
      showSnackBar(S.actSuccess, context: context);
    }
  }
}
