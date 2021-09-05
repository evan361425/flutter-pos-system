import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';

class IconText extends StatelessWidget {
  final String text;
  final IconData icon;
  final TextStyle? textStyle;
  final bool isHint;

  const IconText({
    Key? key,
    required this.text,
    required this.icon,
    this.textStyle,
    this.isHint = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: textStyle?.color, size: textStyle?.fontSize ?? 14),
      isHint ? HintText(' $text') : Text(' $text', style: textStyle),
    ]);
  }
}
