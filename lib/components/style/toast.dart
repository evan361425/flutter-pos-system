import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' as base;

void showToast(BuildContext context, String message) {
  base.FToast()
    ..init(context)
    ..showToast(child: Toast(message: message));
}

class Toast extends StatelessWidget {
  final String message;

  const Toast({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fontColor = colorScheme.brightness == Brightness.dark
        ? colorScheme.onSurface
        : colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: colorScheme.background,
      ),
      child: Text(message, style: TextStyle(color: fontColor)),
    );
  }
}
