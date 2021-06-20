import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final String text;
  final String iconName;
  final TextStyle? textStyle;

  const IconText({
    Key? key,
    required this.text,
    required this.iconName,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? Theme.of(context).textTheme.bodyText1;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(
            text: iconName,
            style: style?.copyWith(fontFamily: 'MaterialIcons'),
          ),
          TextSpan(
            text: ' $text',
          )
        ],
      ),
    );
  }
}
