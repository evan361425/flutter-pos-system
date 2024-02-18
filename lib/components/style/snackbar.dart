import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
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
    action: action,
  ));
}

Future<T?> showSnackbarWhenFailed<T>(
  Future<T?> future,
  BuildContext context,
  String code,
) {
  return future.catchError((err) {
    // print(err);
    // print((err as Error).stackTrace);
    showSnackBar(context, '${S.actError}：$err');
    Log.err(err, code, err is Error ? err.stackTrace : null);
    return null;
  });
}

void showMoreInfoSnackBar(
  BuildContext context,
  String message,
  Widget content, {
  String label = '說明',
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    // make floating button below
    behavior: SnackBarBehavior.floating,
    content: Text(message),
    action: SnackBarAction(
      label: label,
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
    ),
  ));
}
