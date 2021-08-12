import 'package:flutter/material.dart';

class IconFilledButton extends StatelessWidget {
  final VoidCallback onPressed;

  final IconData icon;

  final IconFilledButtonType type;

  const IconFilledButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.type = IconFilledButtonType.outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      visualDensity: VisualDensity(
        horizontal: VisualDensity.minimumDensity,
        vertical: VisualDensity.standard.vertical,
      ),
    );

    switch (type) {
      case IconFilledButtonType.outlined:
        return OutlinedButton(
          style: style,
          onPressed: onPressed,
          child: Icon(icon),
        );
    }
  }
}

enum IconFilledButtonType {
  outlined,
}
