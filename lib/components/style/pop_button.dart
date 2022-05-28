import 'package:flutter/material.dart';

class PopButton extends StatelessWidget {
  final String? title;

  final bool toHome;

  final IconData? icon;

  const PopButton({
    Key? key,
    this.title,
    this.toHome = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (title != null) {
      return TextButton(
        onPressed: () => pop(context),
        child: Text(title!),
      );
    }

    final ic =
        icon ?? (toHome ? Icons.clear_sharp : Icons.arrow_back_ios_sharp);
    return IconButton(
      onPressed: () => pop(context),
      icon: Icon(ic),
    );
  }

  void pop(BuildContext context) {
    toHome
        ? Navigator.of(context).popUntil((route) => route.isFirst)
        : Navigator.of(context).pop();
  }
}
