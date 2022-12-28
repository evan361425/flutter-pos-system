import 'package:flutter/material.dart';

class AppbarTextButton extends StatelessWidget {
  final VoidCallback onPressed;

  final Widget child;

  const AppbarTextButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final textButtonTheme = TextButton.styleFrom(
      foregroundColor: colorScheme.brightness == Brightness.dark
          ? colorScheme.onSurface
          : colorScheme.onPrimary,
    );

    return TextButton(
      style: textButtonTheme,
      onPressed: onPressed,
      child: child,
    );
  }
}
