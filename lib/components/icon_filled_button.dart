import 'package:flutter/material.dart';

class IconFilledButton extends StatelessWidget {
  const IconFilledButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  final Function() onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        visualDensity: VisualDensity(
          horizontal: VisualDensity.minimumDensity,
          vertical: VisualDensity.standard.vertical,
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
