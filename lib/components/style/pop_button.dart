import 'package:flutter/material.dart';

class PopButton extends StatelessWidget {
  final String? title;

  final IconData? icon;

  const PopButton({
    Key? key,
    this.title,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (title != null) {
      return TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(title!),
      );
    }

    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_ios_sharp),
    );
  }
}
