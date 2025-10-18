import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/style/pop_button.dart';
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
    _prettierError(
      err,
      // ignore: use_build_context_synchronously
      context: context,
      key: key,
    );
    Log.err(err, code, err is Error ? err.stackTrace : null);
    callback?.call();
  });
}

Future<T?> showSnackbarWhenFutureError<T>(
  Future<T> future,
  String code, {
  BuildContext? context,
  GlobalKey<ScaffoldMessengerState>? key,
  bool showIfFalse = false,
  String? message,
  String? more,
}) async {
  try {
    Log.out('start', code);
    final result = await future;

    if (showIfFalse && message != null && result == false) {
      showMoreInfoSnackBar(
        message,
        more == null ? null : Linkify.fromString(more),
        // ignore: use_build_context_synchronously
        context: context,
        key: key,
      );
    }

    return result;
  } catch (err) {
    // ignore: use_build_context_synchronously
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
      return AlertDialog.adaptive(
        title: Text(title),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
        content: body,
        actions: [PopButton(title: MaterialLocalizations.of(context).okButtonLabel)],
      );
    },
  );
}

void _prettierError(
  Object e, {
  BuildContext? context,
  GlobalKey<ScaffoldMessengerState>? key,
  String? moreMessage,
}) {
  void show(String msg, [String? more]) {
    if (kDebugMode) {
      print('snackbar debug error: $msg');
      print('snackbar debug stack: ${e is Error ? e.stackTrace : null}');
    }
    showMoreInfoSnackBar(
      msg,
      more == null ? null : Linkify.fromString(more),
      context: context,
      key: key,
    );
  }

  if (e is PlatformException) {
    if (e.message == 'com.google.android.gms.common.api.ApiException: 7: ') {
      return show(S.transitGoogleSheetErrorNetwork);
    }
  }

  if (e is BluetoothOffException) {
    return show(S.printerErrorBluetoothOff);
  }

  if (e is PlatformException && ['connect', 'startScan'].contains(e.code) && e.message?.contains('bluetooth') == true) {
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

  return show(e.toString(), moreMessage);
}
