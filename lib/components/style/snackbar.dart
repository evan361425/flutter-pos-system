import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/translator.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  required Icon icon,
  SnackBarAction? action,
}) {
  // If want to add a "close" button, should consider taking root context, which is hard to handle.
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    // make floating button below
    behavior: SnackBarBehavior.floating,
    // should not use icon, https://material.io/components/snackbars#anatomy
    content: Row(children: [
      icon,
      const SizedBox(width: kSpacing0),
      Text(message),
    ]),
    action: action,
  ));
}

void showSuccessSnackbar(
  BuildContext context,
  String message, [
  SnackBarAction? action,
]) {
  showSnackBar(
    context,
    message,
    icon: const Icon(
      Icons.check_circle_outline_sharp,
      color: Color(0xFF64B5F6),
    ),
    action: action,
  );
}

void showInfoSnackbar(
  BuildContext context,
  String message, [
  SnackBarAction? action,
]) {
  showSnackBar(
    context,
    message,
    icon: const Icon(
      Icons.info_outline,
      color: Color(0xFF81C784),
    ),
    action: action,
  );
}

void showErrorSnackbar(
  BuildContext context,
  String message, [
  SnackBarAction? action,
]) {
  showSnackBar(
    context,
    message,
    icon: Icon(
      Icons.error_outline,
      color: Theme.of(context).colorScheme.error,
    ),
    action: action,
  );
}

Future<T?> showSnackbarWhenFailed<T>(
  Future<T?> future,
  BuildContext context,
  String code,
) {
  return future.catchError((err) {
    showErrorSnackbar(context, S.actError);
    Log.err(err, code, err is Error ? err.stackTrace : null);
    return null;
  });
}
