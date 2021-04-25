import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/models/histories/order_history.dart';
import 'package:possystem/models/repository/cart_model.dart';

class OrderActions extends StatelessWidget {
  const OrderActions({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, OrderActionTypes.pop),
          child: Text('顯示最後一次點餐'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, OrderActionTypes.stash),
          child: Text('暫存本次點餐'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, OrderActionTypes.pop_stash),
          child: Text('顯示暫存餐點'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, OrderActionTypes.leave),
          child: Text('離開點餐頁面'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: Text('取消'),
      ),
    );
  }

  static Future<void> onAction(
    BuildContext context,
    OrderActionTypes action,
  ) async {
    switch (action) {
      case OrderActionTypes.leave:
        return showLeaveConfirm(context);
      case OrderActionTypes.pop:
        if (!await showPopConfirm(context)) return;

        CartModel.instance.stash();

        if (!await CartModel.instance.popHistory()) {
          showSnackbar(context, '找不到當日上一次的紀錄，可以去點單紀錄查詢更久的紀錄');
        }
        return;
      case OrderActionTypes.pop_stash:
        if (!await showPopConfirm(context)) return;

        final order = await OrderHistory.instance.popStash();
        if (order == null) {
          return showSnackbar(context, '目前沒有暫存的紀錄唷');
        }

        CartModel.instance.stash();
        CartModel.instance.updateProductions(order.parseToProduct());
        return;
      case OrderActionTypes.stash:
        return CartModel.instance.stash();
    }
  }

  static Future<void> showLeaveConfirm(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: '確定要回到菜單頁嗎？'),
    );

    if (result == true) Navigator.of(context).pop();
  }

  static Future<bool> showPopConfirm(BuildContext context) async {
    if (CartModel.instance.isEmpty) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: '要暫存本次點餐並顯示舊的單嗎？'),
    );

    return result ?? false;
  }

  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

enum OrderActionTypes {
  pop,
  pop_stash,
  stash,
  leave,
}
