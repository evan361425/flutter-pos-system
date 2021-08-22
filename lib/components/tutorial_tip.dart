import 'package:flutter/material.dart';
import 'package:possystem/components/tip.dart';
import 'package:possystem/services/cache.dart';

class TutorialTip extends StatelessWidget {
  final Widget child;

  final String label;

  final String message;

  final String? title;

  final int version;

  final bool disabled;

  const TutorialTip({
    required this.label,
    this.version = 1,
    required this.message,
    this.title,
    required this.child,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tip(
      title: title,
      message: message,
      disabled: disabled || !Cache.instance.neededTip(label, version),
      onClosed: () => Cache.instance.tipRead(label, version),
      child: child,
    );
  }
}
