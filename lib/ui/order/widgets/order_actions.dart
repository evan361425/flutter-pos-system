import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class OrderActions extends StatelessWidget {
  const OrderActions({Key? key}) : super(key: key);

  List<BottomSheetAction<OrderActionMode>> get actions {
    if (Cart.instance.isHistoryMode) {
      return [
        BottomSheetAction(
          key: const Key('order.action.leave_history'),
          title: Text(S.orderActionsLeaveHistoryMode),
          leading: const Icon(Icons.assignment_return_sharp),
          returnValue: OrderActionMode.leaveHistory,
        ),
      ];
    }

    return [
      BottomSheetAction(
        key: const Key('order.action.show_last'),
        title: Text(S.orderActionsShowLastOrder),
        leading: const Icon(Icons.history_sharp),
        returnValue: OrderActionMode.showLast,
      ),
      BottomSheetAction(
        key: const Key('order.action.changer'),
        title: Text(S.orderActionsOpenChanger),
        leading: const Icon(Icons.change_circle_outlined),
        returnValue: OrderActionMode.changer,
      ),
      BottomSheetAction(
        key: const Key('order.action.stash'),
        title: Text(S.orderActionsStash),
        leading: const Icon(Icons.file_download),
        returnValue: OrderActionMode.stash,
      ),
      BottomSheetAction(
        key: const Key('order.action.drop_stash'),
        title: Text(S.orderActionsDropStash),
        leading: const Icon(Icons.file_upload),
        returnValue: OrderActionMode.dropStash,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final result = await showCircularBottomSheet<OrderActionMode>(
          context,
          actions: actions,
        );
        if (context.mounted) {
          await exec(context, result);
        }
      },
      enableFeedback: true,
      icon: const Icon(KIcons.more),
    );
  }

  Future<void> exec(BuildContext context, OrderActionMode? action) async {
    switch (action) {
      case OrderActionMode.leaveHistory:
        return Cart.instance.clear();
      case OrderActionMode.showLast:
        final f = _confirmAbleToStash(context);
        if (!await f) return;

        if (!await Cart.instance.stash()) {
          if (context.mounted) {
            showInfoSnackbar(context, S.orderActionsStashHitLimit);
          }
          return;
        }

        final success = await Cart.instance.popHistory();
        if (context.mounted) {
          success
              ? showSuccessSnackbar(context, S.actSuccess)
              : showInfoSnackbar(context, S.orderActionsShowLastOrderNotFound);
        }
        return;
      case OrderActionMode.dropStash:
        final f = _confirmAbleToStash(context);
        if (!await f) return;

        final isEmpty = Cart.instance.isEmpty;

        if (!await Cart.instance.stash()) {
          if (context.mounted) {
            showInfoSnackbar(context, S.orderActionsStashHitLimit);
          }
          return;
        }

        final success = await Cart.instance.drop(isEmpty ? 1 : 2);
        if (context.mounted) {
          success
              ? showSuccessSnackbar(context, S.actSuccess)
              : showInfoSnackbar(context, S.orderActionsDropStashNotFound);
        }
        return;
      case OrderActionMode.stash:
        if (Cart.instance.isEmpty) return;

        return await Cart.instance.stash()
            ? showSuccessSnackbar(context, S.actSuccess)
            : showInfoSnackbar(context, S.orderActionsStashHitLimit);
      case OrderActionMode.changer:
        final success =
            await Navigator.of(context).pushNamed(Routes.cashierChanger);

        if (success == true) {
          if (context.mounted) {
            showSuccessSnackbar(context, S.actSuccess);
          }
        }
        return;
      default:
        return;
    }
  }

  Future<bool> _confirmAbleToStash(BuildContext context) async {
    if (Cart.instance.isEmpty) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: S.orderActionsConfirmStashCurrent),
    );

    return result ?? false;
  }
}

enum OrderActionMode {
  showLast,
  changer,
  stash,
  dropStash,
  leaveHistory,
}
