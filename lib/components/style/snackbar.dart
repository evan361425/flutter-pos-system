import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

SnackBar createSnackBar(
  String message, {
  required Icon icon,
  duration = const Duration(milliseconds: 600),
}) {
  return SnackBar(
    margin: const EdgeInsets.fromLTRB(kSpacing2, 0, kSpacing2, kSpacing4),
    behavior: SnackBarBehavior.floating,
    duration: duration,
    content: Row(children: [
      icon,
      const SizedBox(width: kSpacing0),
      Text(message),
    ]),
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message,
      icon: const Icon(
        Icons.check_circle_outline_sharp,
        color: Color(0xFF64B5F6),
      )));
}

void showInfoSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(createSnackBar(
    message,
    duration: const Duration(seconds: 3),
    icon: const Icon(
      Icons.info_outline,
      color: Color(0xFF81C784),
    ),
  ));
}
