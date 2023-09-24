import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/more_button.dart';
import 'package:possystem/components/style/snackbar.dart';
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
    return MoreButton(
      onPressed: () async {
        final result = await showCircularBottomSheet<OrderActionMode>(
          context,
          actions: actions,
        );
        if (context.mounted) {
          await exec(context, result);
        }
      },
    );
  }

  Future<void> exec(BuildContext context, OrderActionMode? action) async {
    switch (action) {
      case OrderActionMode.leaveHistory:
        return Cart.instance.clear();
      case OrderActionMode.showLast:
        final confirmed = await _confirmAbleToStash(context);
        if (!confirmed) return;

        if (!await Cart.instance.stash()) {
          if (context.mounted) {
            showSnackBar(context, S.orderActionsStashHitLimit);
          }
          return;
        }

        final success = await Cart.instance.popHistory();
        if (context.mounted) {
          success
              ? showSnackBar(context, S.actSuccess)
              : showSnackBar(context, S.orderActionsShowLastOrderNotFound);
        }
        return;
      case OrderActionMode.dropStash:
        bool confirmed = false;
        if (context.mounted) confirmed = await _confirmAbleToStash(context);
        if (!confirmed) return;

        final isEmpty = Cart.instance.isEmpty;

        if (!await Cart.instance.stash()) {
          if (context.mounted) {
            showSnackBar(context, S.orderActionsStashHitLimit);
          }
          return;
        }

        /// 如果他本來沒有 Stash，在上面又 Stash 一個餐點，這時資料庫只有一次暫存資料。
        /// 此時要避免傳入 2，但是在 database 的 getLast 中已經避免此事。
        final success = await Cart.instance.drop(isEmpty ? 1 : 2);
        if (context.mounted) {
          success
              ? showSnackBar(context, S.actSuccess)
              : showSnackBar(context, S.orderActionsDropStashNotFound);
        }
        return;
      case OrderActionMode.stash:
        if (Cart.instance.isEmpty) return;

        final success = await Cart.instance.stash();
        if (context.mounted) {
          success
              ? showSnackBar(context, S.actSuccess)
              : showSnackBar(context, S.orderActionsStashHitLimit);
        }
        return;
      case OrderActionMode.changer:
        bool? success;
        if (context.mounted) {
          success = await context.pushNamed(Routes.cashierChanger);
        }

        if (success == true) {
          if (context.mounted) {
            showSnackBar(context, S.actSuccess);
          }
        }
        return;
      default:
        return;
    }
  }

  Future<bool> _confirmAbleToStash(BuildContext context) async {
    if (Cart.instance.isEmpty) return true;

    return await ConfirmDialog.show(
      context,
      title: S.orderActionsConfirmStashCurrent,
    );
  }
}

enum OrderActionMode {
  showLast,
  changer,
  stash,
  dropStash,
  leaveHistory,
}
