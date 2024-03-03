import 'package:flutter/material.dart';

class PopButton extends StatelessWidget {
  final String? title;

  final VoidCallback? onPressed;

  const PopButton({
    super.key,
    this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (title != null) {
      return TextButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: Text(title!),
      );
    }

    return BackButton(
      key: const Key('pop'),
      onPressed: onPressed,
    );
  }
}
