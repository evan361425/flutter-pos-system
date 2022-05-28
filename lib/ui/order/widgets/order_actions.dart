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

  List<BottomSheetAction<_Types>> get actions {
    if (Cart.instance.isHistoryMode) {
      return [
        BottomSheetAction(
          key: const Key('order.action.leave_history'),
          title: Text(S.orderActionsLeaveHistoryMode),
          leading: const Icon(Icons.assignment_return_sharp),
          returnValue: _Types.leaveHistory,
        ),
      ];
    }

    return [
      BottomSheetAction(
        key: const Key('order.action.show_last'),
        title: Text(S.orderActionsShowLastOrder),
        leading: const Icon(Icons.history_sharp),
        returnValue: _Types.showLast,
      ),
      BottomSheetAction(
        key: const Key('order.action.changer'),
        title: Text(S.orderActionsOpenChanger),
        leading: const Icon(Icons.change_circle_outlined),
        returnValue: _Types.changer,
      ),
      BottomSheetAction(
        key: const Key('order.action.stash'),
        title: Text(S.orderActionsStash),
        leading: const Icon(Icons.file_download),
        returnValue: _Types.stash,
      ),
      BottomSheetAction(
        key: const Key('order.action.drop_stash'),
        title: Text(S.orderActionsDropStash),
        leading: const Icon(Icons.file_upload),
        returnValue: _Types.dropStash,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final result = await showCircularBottomSheet<_Types>(
          context,
          actions: actions,
        );
        await exec(context, result);
      },
      enableFeedback: true,
      icon: const Icon(KIcons.more),
    );
  }

  Future<void> exec(BuildContext context, _Types? action) async {
    switch (action) {
      case _Types.leaveHistory:
        return Cart.instance.clear();
      case _Types.showLast:
        if (!await _confirmStashable(context)) return;

        if (!await Cart.instance.stash()) {
          return showInfoSnackbar(context, S.orderActionsStashHitLimit);
        }

        final success = await Cart.instance.popHistory();
        success
            ? showSuccessSnackbar(context, S.actSuccess)
            : showInfoSnackbar(context, S.orderActionsShowLastOrderNotFound);
        return;
      case _Types.dropStash:
        if (!await _confirmStashable(context)) return;

        final isEmpty = Cart.instance.isEmpty;

        if (!await Cart.instance.stash()) {
          return showInfoSnackbar(
            context,
            S.orderActionsStashHitLimit,
          );
        }

        final success = await Cart.instance.drop(isEmpty ? 1 : 2);
        return success
            ? showSuccessSnackbar(context, S.actSuccess)
            : showInfoSnackbar(context, S.orderActionsDropStashNotFound);
      case _Types.stash:
        if (Cart.instance.isEmpty) return;

        return await Cart.instance.stash()
            ? showSuccessSnackbar(context, S.actSuccess)
            : showInfoSnackbar(context, S.orderActionsStashHitLimit);
      case _Types.changer:
        final success =
            await Navigator.of(context).pushNamed(Routes.cashierChanger);

        if (success == true) {
          showSuccessSnackbar(context, S.actSuccess);
        }
        return;
      default:
        return;
    }
  }

  Future<bool> _confirmStashable(BuildContext context) async {
    if (Cart.instance.isEmpty) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: S.orderActionsConfirmStashCurrent),
    );

    return result ?? false;
  }
}

enum _Types {
  showLast,
  changer,
  stash,
  dropStash,
  leaveHistory,
}
