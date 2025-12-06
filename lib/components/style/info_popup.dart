import 'package:flutter/material.dart';

class InfoPopup extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry margin;

  const InfoPopup(
    this.message, {
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 30),
      margin: margin,
      child: const Icon(Icons.help_outline_outlined),
    );
  }
}
