import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class OutlinedText extends StatelessWidget {
  final String text;

  final String? badge;

  final bool colored;

  const OutlinedText(
    this.text, {
    Key? key,
    this.badge,
    this.colored = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.primaryColor;
    final textColor = theme.colorScheme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;
    final base = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.fromLTRB(kSpacing1, 4.0, kSpacing1, 4.0),
      constraints: const BoxConstraints(minWidth: 64.0),
      decoration: BoxDecoration(
        color: colored ? color : null,
        border: Border.all(color: colored ? color : const Color(0xDD000000)),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: colored ? textColor : null),
      ),
    );

    if (badge != null) {
      return Stack(alignment: Alignment.center, children: [
        base,
        Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), color: color),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(badge!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: textColor)),
            ))
      ]);
    }

    return base;
  }
}
