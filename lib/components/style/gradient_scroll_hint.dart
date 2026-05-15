import 'package:flutter/material.dart';

/// GradientScrollHint help to show a gradient hint when the content is scrollable.
class GradientScrollHint extends StatelessWidget {
  final Axis direction;

  final bool isDialog;

  const GradientScrollHint({super.key, this.direction = .horizontal, this.isDialog = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = (isDialog ? theme.dialogTheme.backgroundColor : null) ?? theme.colorScheme.surfaceContainerHigh;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: direction == .horizontal ? Alignment.centerRight : Alignment.topCenter,
            end: direction == .horizontal ? Alignment.centerLeft : Alignment.bottomCenter,
            colors: [color.withAlpha(0), color],
          ),
        ),
      ),
    );
  }
}
