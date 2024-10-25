import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/bluetooth.dart';
import 'package:possystem/translator.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  // If want to add a "close" button, should consider taking root context, which is hard to handle.
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    showCloseIcon: true,
    // make floating button below
    behavior: SnackBarBehavior.floating,
    content: Text(message),
    width: MediaQuery.sizeOf(context).width > 700 ? 600 : null,
    action: action,
  ));
}

Stream<T> showSnackbarWhenError<T>(Stream<T> stream, BuildContext context, String code) {
  stream.handleError((err) {
    if (context.mounted) {
      final e = _prettierError(err);
      showMoreInfoSnackBar(context, '${S.actError}: ${e.message}', e.moreWidget);
    }
    Log.err(err, code, err is Error ? err.stackTrace : null);
  });

  return stream;
}

Future<T?> showSnackbarWhenFailed<T>(
  Future<T> future,
  BuildContext context,
  String code,
) async {
  try {
    return await future;
  } catch (err) {
    if (context.mounted) {
      final e = _prettierError(err);
      showMoreInfoSnackBar(context, '${S.actError}: ${e.message}', e.moreWidget);
    }
    Log.err(err, code, err is Error ? err.stackTrace : null);
    return null;
  }
}

void showMoreInfoSnackBar(BuildContext context, String message, Widget? content) {
  final action = content == null
      ? null
      : SnackBarAction(
          label: S.actMoreInfo,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: Text(message),
                  contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
                  children: [content],
                );
              },
            );
          },
        );

  showSnackBar(context, message, action: action);
}

_PrettierError _prettierError(Object e) {
  if (e is BluetoothOffException) {
    return const _PrettierError('藍牙未開啟');
  }

  if (e is BluetoothException) {
    if (e.code == BluetoothExceptionCode.timeout.index) {
      return const _PrettierError('連線逾時', more: '聯絡不到該裝置，可以嘗試以下操作：\n• 確認裝置是否開啟\n• 確認裝置是否在範圍內\n• 重新開啟藍牙');
    }

    if (e.code == BluetoothExceptionCode.deviceIsDisconnected.index) {
      return const _PrettierError('裝置已斷線');
    }

    if ([
      BluetoothExceptionCode.serviceNotFound.index,
      BluetoothExceptionCode.characteristicNotFound.index,
    ].contains(e.code)) {
      return const _PrettierError('裝置不相容', more: '目前尚未支援此裝置，你可以[聯絡我們](mailto:evanlu361425@gmail.com)以取得支援。');
    }

    if ([
      BluetoothExceptionCode.adapterIsOff.index,
      BluetoothExceptionCode.connectionCanceled.index,
      BluetoothExceptionCode.userRejected.index,
    ].contains(e.code)) {
      return const _PrettierError('連線請求被中斷');
    }

    return _PrettierError(e.description ?? 'error from ${e.function}');
  }

  return _PrettierError(e.toString());
}

class _PrettierError {
  final String message;
  final String? more;

  const _PrettierError(this.message, {this.more});

  Widget? get moreWidget => more == null ? null : Text(more!);
}
