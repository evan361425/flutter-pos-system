import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/translator.dart';

void showSnackBar(
  String message, {
  BuildContext? context,
  GlobalKey<ScaffoldMessengerState>? key,
  SnackBarAction? action,
}) {
  ScaffoldMessengerState? state;
  if (context != null) {
    if (context.mounted) {
      state = ScaffoldMessenger.maybeOf(context);
    }
  } else {
    if (key?.currentContext?.mounted == true) {
      state = key?.currentState;
    }
  }

  if (state != null) {
    state.clearSnackBars();
    // If want to add a "close" button, should consider taking root context, which is hard to handle.
    state.showSnackBar(SnackBar(
      showCloseIcon: true,
      // make floating button below
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      width: Routes.homeMode.value.isMobile() ? null : 600,
      action: action,
    ));
  }
}

Stream<T> showSnackbarWhenStreamError<T>(
  Stream<T> stream,
  String code, {
  BuildContext? context,
  GlobalKey<ScaffoldMessengerState>? key,
}) {
  stream.handleError((err) {
    _prettierError(err);
    Log.err(err, code, err is Error ? err.stackTrace : null);
  });

  return stream;
}

Future<T?> showSnackbarWhenFutureError<T>(
  Future<T> future,
  String code, {
  BuildContext? context,
  GlobalKey<ScaffoldMessengerState>? key,
}) async {
  try {
    return await future;
  } catch (err) {
    _prettierError(err, context: context, key: key);
    Log.err(err, code, err is Error ? err.stackTrace : null);
    return null;
  }
}

void showMoreInfoSnackBar(
  String message,
  Widget? content, {
  BuildContext? context,
  GlobalKey<ScaffoldMessengerState>? key,
}) {
  final ctx = context ?? key?.currentContext;
  final action = content == null || ctx == null
      ? null
      : SnackBarAction(
          label: S.actMoreInfo,
          onPressed: () => showMoreInfoDialog(ctx, message, content),
        );

  showSnackBar(message, action: action, context: context, key: key);
}

void showMoreInfoDialog(BuildContext context, String title, Widget body) {
  showAdaptiveDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text(title),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
        children: [body],
      );
    },
  );
}

void _prettierError(Object e, {BuildContext? context, GlobalKey<ScaffoldMessengerState>? key}) {
  void show(String msg, [String? more]) {
    showMoreInfoSnackBar(msg, more == null ? null : Text(more), context: context, key: key);
  }

  if (e is BluetoothOffException) {
    return show('藍牙未開啟');
  }

  if (e is BluetoothException) {
    if (e.code == BluetoothExceptionCode.timeout.index) {
      return show('連線逾時', '聯絡不到該裝置，可以嘗試以下操作：\n• 確認裝置是否開啟\n• 確認裝置是否在範圍內\n• 重新開啟藍牙');
    }

    if (e.code == BluetoothExceptionCode.deviceIsDisconnected.index) {
      return show('裝置已斷線');
    }

    if ([
      BluetoothExceptionCode.serviceNotFound.index,
      BluetoothExceptionCode.characteristicNotFound.index,
    ].contains(e.code)) {
      return show('裝置不相容', '目前尚未支援此裝置，你可以[聯絡我們](mailto:evanlu361425@gmail.com)以取得支援。');
    }

    if ([
      BluetoothExceptionCode.adapterIsOff.index,
      BluetoothExceptionCode.connectionCanceled.index,
      BluetoothExceptionCode.userRejected.index,
    ].contains(e.code)) {
      return show('連線請求被中斷');
    }

    return show(e.description ?? 'error from ${e.function}');
  }

  return show(e.toString());
}
