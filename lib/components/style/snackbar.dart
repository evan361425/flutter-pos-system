import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/translator.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  // If want to add a "close" button, should consider taking root context, which is hard to handle.
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    showCloseIcon: true,
    // make floating button below
    behavior: SnackBarBehavior.floating,
    content: Text(message),
    action: action,
  ));
}

Future<T?> showSnackbarWhenFailed<T>(
  Future<T?> future,
  BuildContext context,
  String code,
) {
  return future.catchError((err) {
    showSnackBar(context, '${S.actError}：$err');
    Log.err(err, code, err is Error ? err.stackTrace : null);
    return null;
  });
}
