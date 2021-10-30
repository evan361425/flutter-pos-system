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
          title: Text(tt('order.action.leave_history')),
          leading: const Icon(Icons.assignment_return_sharp),
          returnValue: _Types.leaveHistory,
        ),
      ];
    }

    return [
      BottomSheetAction(
        key: const Key('order.action.show_last'),
        title: Text(tt('order.action.show_last')),
        leading: const Icon(Icons.history_sharp),
        returnValue: _Types.showLast,
      ),
      const BottomSheetAction(
        key: Key('order.action.changer'),
        title: Text('換錢'),
        leading: Icon(Icons.change_circle_outlined),
        returnValue: _Types.changer,
      ),
      BottomSheetAction(
        key: const Key('order.action.stash'),
        title: Text(tt('order.action.stash')),
        leading: const Icon(Icons.file_download),
        returnValue: _Types.stash,
      ),
      BottomSheetAction(
        key: const Key('order.action.drop_stash'),
        title: Text(tt('order.action.drop_stash')),
        leading: const Icon(Icons.file_upload),
        returnValue: _Types.dropStash,
      ),
      BottomSheetAction(
        key: const Key('order.action.leave'),
        title: Text(tt('order.action.leave')),
        leading: const Icon(Icons.logout),
        returnValue: _Types.leave,
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
      icon: const Icon(KIcons.more),
    );
  }

  Future<void> exec(BuildContext context, _Types? action) async {
    switch (action) {
      case _Types.leaveHistory:
        return Cart.instance.clear();
      case _Types.leave:
        return Navigator.of(context).pop();
      case _Types.showLast:
        if (!await _confirmStashable(context)) return;

        if (!await Cart.instance.stash()) {
          return showInfoSnackbar(
              context, tt('order.action.error.stash_limit'));
        }

        final success = await Cart.instance.popHistory();
        success
            ? showSuccessSnackbar(context, tt('success'))
            : showInfoSnackbar(context, tt('order.action.error.last_empty'));
        return;
      case _Types.dropStash:
        if (!await _confirmStashable(context)) return;

        final isEmpty = Cart.instance.isEmpty;

        if (!await Cart.instance.stash()) {
          return showInfoSnackbar(
            context,
            tt('order.action.error.stash_limit'),
          );
        }

        final success = await Cart.instance.drop(isEmpty ? 1 : 2);
        return success
            ? showSuccessSnackbar(context, tt('success'))
            : showInfoSnackbar(context, tt('order.action.error.stash_empty'));
      case _Types.stash:
        if (Cart.instance.isEmpty) return;

        return await Cart.instance.stash()
            ? showSuccessSnackbar(context, tt('success'))
            : showInfoSnackbar(context, tt('order.action.error.stash_limit'));
      case _Types.changer:
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

  Future<bool> _confirmStashable(BuildContext context) async {
    if (Cart.instance.isEmpty) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: tt('order.action.confirm.stash')),
    );

    return result ?? false;
  }
}

enum _Types {
  showLast,
  changer,
  stash,
  dropStash,
  leave,
  leaveHistory,
}
