import 'package:flutter/material.dart';

class IconFilledButton extends StatelessWidget {
  final VoidCallback onPressed;

  final IconData icon;

  const IconFilledButton({
    Key? key,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

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
      child: Icon(icon),
    );
  }
}
