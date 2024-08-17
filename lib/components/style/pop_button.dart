import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/routes.dart';

class PopButton extends StatelessWidget {
  final String? title;

  final VoidCallback? onPressed;

  const PopButton({
    super.key,
    this.title,
    this.onPressed,
  });

  static safePop(BuildContext context, [path = Routes.base]) {
    if (context.mounted) {
      context.canPop() ? context.pop() : context.go(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    cb() => onPressed == null ? safePop(context) : onPressed!();

    if (title != null) {
      return TextButton(
        onPressed: cb,
        child: Text(title!),
      );
    }

    return BackButton(
      key: const Key('pop'),
      onPressed: cb,
    );
  }
}
