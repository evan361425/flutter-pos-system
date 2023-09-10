import 'package:flutter/material.dart';

class PopButton extends StatelessWidget {
  final String? title;

  final IconData? icon;

  final VoidCallback? onPressed;

  const PopButton({
    Key? key,
    this.title,
    this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    maybePop() => Navigator.of(context).maybePop();

    if (title != null) {
      return TextButton(
        onPressed: maybePop,
        child: Text(title!),
      );
    }

    return icon == null
        ? BackButton(
            key: const Key('pop'),
            onPressed: onPressed,
          )
        : IconButton(
            key: const Key('pop'),
            onPressed: maybePop,
            icon: Icon(icon),
          );
  }
}
