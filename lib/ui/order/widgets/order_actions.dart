import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/cashier/changer/changer_dialog.dart';

class OrderActions {
  static List<Widget> actions(BuildContext context) {
    if (Cart.instance.isHistoryMode) {
      return [
        ListTile(
          title: Text(tt('order.action.leave_history')),
          leading: Icon(Icons.assignment_return_sharp),
          onTap: () => Navigator.pop(context, OrderActionTypes.leave_history),
        ),
      ];
    }

    return [
      ListTile(
        title: Text(tt('order.action.show_last')),
        leading: Icon(Icons.history_sharp),
        onTap: () => Navigator.pop(context, OrderActionTypes.show_last),
      ),
      ListTile(
        title: Text('換錢'),
        leading: Icon(Icons.change_circle_outlined),
        onTap: () => Navigator.pop(context, OrderActionTypes.changer),
      ),
      ListTile(
        title: Text(tt('order.action.stash')),
        leading: Icon(Icons.file_download),
        onTap: () => Navigator.pop(context, OrderActionTypes.stash),
      ),
      ListTile(
        title: Text(tt('order.action.drop_stash')),
        leading: Icon(Icons.file_upload),
        onTap: () => Navigator.pop(context, OrderActionTypes.drop_stash),
      ),
      ListTile(
        title: Text(tt('order.action.leave')),
        leading: Icon(Icons.logout),
        onTap: () => Navigator.pop(context, OrderActionTypes.leave),
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
          return _showSnackbar(context, tt('order.action.error.stash_limit'));
        }

        final success = await Cart.instance.popHistory();
        _showSnackbar(context,
            success ? tt('success') : tt('order.action.error.last_empty'));
        return;
      case OrderActionTypes.drop_stash:
        if (!await _confirmStashCurrent(context)) return;

        if (!await Cart.instance.stash()) {
          return _showSnackbar(context, tt('order.action.error.stash_limit'));
        }

        final success = await Cart.instance.drop();
        return _showSnackbar(context,
            success ? tt('success') : tt('order.action.error.stash_empty'));
      case OrderActionTypes.stash:
        final success = await Cart.instance.stash();
        return _showSnackbar(context,
            success ? tt('success') : tt('order.action.error.stash_limit'));
      case OrderActionTypes.changer:
        final success = await showDialog<bool>(
          context: context,
          builder: (_) => ChangerDialog(),
        );

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

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
