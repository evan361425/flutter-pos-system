import 'package:flutter/material.dart';

class ExpansionActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final Widget label;
  final bool isDanger;

  const ExpansionActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isDanger = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Theme.of(context).errorColor : null;

    final coloredIcon = color == null ? icon : Icon(icon.icon, color: color);
    final coloredLabel = color == null
        ? label
        : DefaultTextStyle(
            style: TextStyle(color: color),
            child: label,
          );

    return OutlinedButton(
      onPressed: onPressed,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        coloredIcon,
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: coloredLabel,
          ),
        ),
      ]),
    );
  }
}
