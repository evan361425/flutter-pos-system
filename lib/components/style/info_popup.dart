import 'package:flutter/material.dart';

class InfoPopup extends StatelessWidget {
  final String message;

  const InfoPopup(
    this.message, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 30),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: const Icon(Icons.help_outline_outlined),
    );
  }
}
