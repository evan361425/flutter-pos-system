import 'package:flutter/material.dart';

/// GradientScrollHint help to show a gradient hint when the content is scrollable.
class GradientScrollHint extends StatelessWidget {
  final Axis direction;

  final bool isDialog;

  const GradientScrollHint({
    super.key,
    this.direction = Axis.horizontal,
    this.isDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDialog ? theme.dialogBackgroundColor : theme.scaffoldBackgroundColor;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: direction == Axis.horizontal ? Alignment.centerRight : Alignment.topCenter,
            end: direction == Axis.horizontal ? Alignment.centerLeft : Alignment.bottomCenter,
            colors: [color.withAlpha(0), color],
          ),
        ),
      ),
    );
  }
}
