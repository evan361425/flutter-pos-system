import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

SnackBar createSnackBar(String message, {required Icon icon}) {
  return SnackBar(
    margin: const EdgeInsets.all(kSpacing2),
    behavior: SnackBarBehavior.floating,
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
    icon: const Icon(
      Icons.info_outline,
      color: Color(0xFF81C784),
    ),
  ));
}
