import 'package:flutter/material.dart';

class PopButton extends StatelessWidget {
  final String? title;

  final VoidCallback? onPressed;

  const PopButton({
    Key? key,
    this.title,
    this.onPressed,
  }) : super(key: key);

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
