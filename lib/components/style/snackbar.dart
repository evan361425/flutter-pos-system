import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/components/linkify.dart';
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

/// Show snackbar when stream error
///
/// - [stream] the stream to listen
/// - [code] the error code
/// - [context] the context to show snackbar
/// - [key] the ScaffoldMessengerState to show snackbar
/// - [callback] the callback to call when error
Stream<T> showSnackbarWhenStreamError<T>(
  Stream<T> stream,
  String code, {
  BuildContext? context,
  GlobalKey<ScaffoldMessengerState>? key,
  VoidCallback? callback,
}) {
  return stream.handleError((err) {
    _prettierError(err);
    Log.err(err, code, err is Error ? err.stackTrace : null);
    callback?.call();
  });
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
    showMoreInfoSnackBar(
      msg,
      more == null ? null : Linkify.fromString(more),
      context: context,
      key: key,
    );
  }

  if (e is BluetoothOffException) {
    return show(S.printerErrorBluetoothOff);
  }

  if (e is PlatformException && e.code == 'connect' && e.message?.contains('bluetooth') == true) {
    return show(S.printerErrorBluetoothOff);
  }

  if (e is BluetoothException) {
    if (e.code == BluetoothExceptionCode.timeout.index) {
      return show(S.printerErrorTimeout, S.printerErrorTimeoutMore);
    }

    if (e.code == BluetoothExceptionCode.deviceIsDisconnected.index) {
      return show(S.printerErrorDisconnected);
    }

    if ([
      BluetoothExceptionCode.serviceNotFound.index,
      BluetoothExceptionCode.characteristicNotFound.index,
    ].contains(e.code)) {
      return show(S.printerErrorNotSupportTitle, S.printerErrorNotSupportContent);
    }

    if ([
          BluetoothExceptionCode.adapterIsOff.index,
          BluetoothExceptionCode.connectionCanceled.index,
          BluetoothExceptionCode.userRejected.index,
        ].contains(e.code) ||
        e.description == 'ANDROID_SPECIFIC_ERROR') {
      return show(S.printerErrorCanceled);
    }

    return show(e.description ?? 'error from ${e.function}');
  }

  return show(e.toString());
}
