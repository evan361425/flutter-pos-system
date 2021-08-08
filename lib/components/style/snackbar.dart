import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  required Icon icon,
}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    margin: const EdgeInsets.all(kSpacing2),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: '關閉',
      onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
    ),
    content: Row(children: [
      icon,
      const SizedBox(width: kSpacing0),
      Text(message),
    ]),
  ));
}

void showSuccessSnackbar(BuildContext context, String message) {
  showSnackBar(context, message,
      icon: const Icon(
        Icons.check_circle_outline_sharp,
        color: Color(0xFF64B5F6),
      ));
}

void showInfoSnackbar(BuildContext context, String message) {
  showSnackBar(context, message,
      icon: const Icon(
        Icons.info_outline,
        color: Color(0xFF81C784),
      ));
}
