import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/models/repository/cart_model.dart';

class OrderActions {
  static List<Widget> actions(BuildContext context) {
    if (CartModel.instance.isHistoryMode) {
      return [
        ListTile(
          title: Text('退出改單模式'),
          leading: Icon(Icons.assignment_return_sharp),
          onTap: () => Navigator.pop(context, OrderActionTypes.leave_history),
        ),
      ];
    }

    return [
      ListTile(
        title: Text('顯示最後一次點餐'),
        leading: Icon(Icons.history_sharp),
        onTap: () => Navigator.pop(context, OrderActionTypes.show_last),
      ),
      ListTile(
        title: Text('暫存本次點餐'),
        leading: Icon(Icons.file_download),
        onTap: () => Navigator.pop(context, OrderActionTypes.stash),
      ),
      ListTile(
        title: Text('拉出暫存餐點'),
        leading: Icon(Icons.file_upload),
        onTap: () => Navigator.pop(context, OrderActionTypes.drop_stash),
      ),
      ListTile(
        title: Text('離開點餐頁面'),
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
        return CartModel.instance.leaveHistoryMode();
      case OrderActionTypes.leave:
        return Navigator.of(context).pop();
      case OrderActionTypes.show_last:
        if (!await _confirmStashCurrent(context)) return;

        if (!await CartModel.instance.stash()) {
          return _showSnackbar(context, '暫存檔案的次數超過上限');
        }

        final success = await CartModel.instance.popHistory();
        _showSnackbar(context, success ? '執行成功' : '找不到當日上一次的紀錄，可以去點單紀錄查詢更久的紀錄');
        return;
      case OrderActionTypes.drop_stash:
        if (!await _confirmStashCurrent(context)) return;

        if (!await CartModel.instance.stash()) {
          return _showSnackbar(context, '暫存檔案的次數超過上限');
        }

        final success = await CartModel.instance.drop();
        return _showSnackbar(context, success ? '執行成功' : '目前沒有暫存的紀錄唷');
      case OrderActionTypes.stash:
        if (!await CartModel.instance.stash()) {
          _showSnackbar(context, '暫存檔案的次數超過上限');
        }
        return;
      default:
        return;
    }
  }

  static Future<bool> _confirmStashCurrent(BuildContext context) async {
    if (CartModel.instance.isEmpty) return true;

    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: '要暫存本次點餐並顯示舊的單嗎？'),
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
  drop_stash,
  stash,
  leave,
  leave_history,
}
