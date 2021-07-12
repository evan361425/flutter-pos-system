import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final String text;
  final IconData icon;
  final TextStyle? textStyle;

  const IconText({
    Key? key,
    required this.text,
    required this.icon,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: textStyle?.color, size: textStyle?.fontSize ?? 14),
      Text(' $text', style: textStyle),
    ]);
  }
}
