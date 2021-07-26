import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class OrderActions {
  static List<BottomSheetAction> actions() {
    if (Cart.instance.isHistoryMode) {
      return [
        BottomSheetAction(
          title: Text(tt('order.action.leave_history')),
          leading: Icon(Icons.assignment_return_sharp),
          onTap: (context) {
            Navigator.pop(context, OrderActionTypes.leave_history);
          },
        ),
      ];
    }

    return [
      BottomSheetAction(
        title: Text(tt('order.action.show_last')),
        leading: Icon(Icons.history_sharp),
        onTap: (context) => Navigator.pop(context, OrderActionTypes.show_last),
      ),
      BottomSheetAction(
        title: Text('換錢'),
        leading: Icon(Icons.change_circle_outlined),
        onTap: (context) => Navigator.pop(context, OrderActionTypes.changer),
      ),
      BottomSheetAction(
        title: Text(tt('order.action.stash')),
        leading: Icon(Icons.file_download),
        onTap: (context) => Navigator.pop(context, OrderActionTypes.stash),
      ),
      BottomSheetAction(
        title: Text(tt('order.action.drop_stash')),
        leading: Icon(Icons.file_upload),
        onTap: (context) => Navigator.pop(context, OrderActionTypes.drop_stash),
      ),
      BottomSheetAction(
        title: Text(tt('order.action.leave')),
        leading: Icon(Icons.logout),
        onTap: (context) => Navigator.pop(context, OrderActionTypes.leave),
      ),
    ];
  }

  static Future<void> onAction(
    BuildContext context,
    OrderActionTypes? action,
  ) async {
    switch (action) {
      case OrderActionTypes.leave_history:
        return Cart.instance.leaveHistoryMode();
      case OrderActionTypes.leave:
        return Navigator.of(context).pop();
      case OrderActionTypes.show_last:
        if (!await _confirmStashCurrent(context)) return;

        if (!await Cart.instance.stash()) {
          return showInfoSnackbar(
            context,
            tt('order.action.error.stash_limit'),
          );
        }

        final success = await Cart.instance.popHistory();
        success
            ? showSuccessSnackbar(context, tt('success'))
            : showInfoSnackbar(context, tt('order.action.error.last_empty'));
        return;
      case OrderActionTypes.drop_stash:
        if (!await _confirmStashCurrent(context)) return;

        if (!await Cart.instance.stash()) {
          return showInfoSnackbar(
            context,
            tt('order.action.error.stash_limit'),
          );
        }

        final success = await Cart.instance.drop();
        return success
            ? showSuccessSnackbar(context, tt('success'))
            : showInfoSnackbar(context, tt('order.action.error.stash_empty'));
      case OrderActionTypes.stash:
        final success = await Cart.instance.stash();
        return success
            ? showSuccessSnackbar(context, tt('success'))
            : showInfoSnackbar(context, tt('order.action.error.stash_limit'));
      case OrderActionTypes.changer:
        final success =
            await Navigator.of(context).pushNamed(Routes.cashierChanger);

        if (success == true) {
          showSuccessSnackbar(context, tt('success'));
        }
        return;
      default:
        return;
    }
  }

  static Future<bool> _confirmStashCurrent(BuildContext context) async {
    if (Cart.instance.isEmpty) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: tt('order.action.confirm.stash')),
    );

    return result ?? false;
  }
}

enum OrderActionTypes {
  show_last,
  changer,
  stash,
  drop_stash,
  leave,
  leave_history,
}
