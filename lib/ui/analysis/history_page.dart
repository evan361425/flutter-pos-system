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
              child: PopupMenuButton<_Action>(
                key: const Key('history.action'),
                icon: const Icon(KIcons.more),
                itemBuilder: _buildActions,
                onSelected: (value) async {
                  final success = await _onActionSelected(value);
                  if (success && context.mounted) {
                    showSnackBar(S.actSuccess, context: context);
                  }
                },
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

  List<PopupMenuItem<_Action>> _buildActions(BuildContext context) {
    return [
      PopupMenuItem<_Action>(
        value: _Action.export,
        child: PopupMenuButton<TransitMethod>(
          key: const Key('history.action.export'),
          itemBuilder: (context) => TransitMethod.values
              .map((TransitMethod value) => PopupMenuItem<TransitMethod>(
                    value: value,
                    child: Text(value.l10nName),
                  ))
              .toList(),
          onSelected: (value) => _onActionSelected(_Action.export, pathParameters: {
            'method': value.name,
            'catalog': 'order',
          }),
          child: Text(S.analysisHistoryActionExport),
        ),
      ),
      PopupMenuItem<_Action>(
        value: _Action.clear,
        child: Text(S.analysisHistoryActionClear),
      ),
      PopupMenuItem<_Action>(
        value: _Action.resetNo,
        child: Text(S.analysisHistoryActionResetNo),
      ),
      PopupMenuItem<_Action>(
        value: _Action.scheduleResetNo,
        child: Text(S.analysisHistoryActionScheduleResetNo),
      ),
    ];
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

  Future<bool> _onActionSelected(_Action action, {Map<String, String>? pathParameters}) async {
    switch (action) {
      case _Action.export:
        if (pathParameters != null) {
          // Close the parent popup menu
          Navigator.pop(context);
          await context.pushNamed(
            Routes.transitStation,
            pathParameters: pathParameters,
            queryParameters: {'range': serializeRange(notifier.value)},
          );
        }
      case _Action.clear:
        final dateTime = await HistoryCleanDialog.show(context);
        if (dateTime != null && context.mounted) {
          await Seller.instance.clean(dateTime);
          return true;
        }
        break;
      case _Action.resetNo:
        final ok = await ConfirmDialog.show(
          context,
          title: S.analysisHistoryActionResetNo,
          content: S.analysisHistoryActionResetNoHint,
        );
        if (ok) {
          await Seller.instance.resetId();
          return true;
        }
        break;
      case _Action.scheduleResetNo:
        final period = await HistoryScheduleResetNoDialog.show(context);
        if (period != null && context.mounted) {
          await Seller.instance.updateResetIdPeriod(period);
          return true;
        }
    }

    return false;
  }
}

enum _Action {
  export,
  clear,
  resetNo,
  scheduleResetNo,
}
