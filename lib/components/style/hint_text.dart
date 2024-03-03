import 'package:flutter/material.dart';

class HintText extends StatelessWidget {
  final String text;

  final TextOverflow? overflow;

  final TextAlign? textAlign;

  const HintText(
    this.text, {
    super.key,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall!.copyWith(
      color: theme.hintColor,
      inherit: true,
    );

    return Text(
      text,
      style: style,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

  static TextSpan inSpan(BuildContext context, String text) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall!.copyWith(
      color: theme.hintColor,
      inherit: true,
    );

    return TextSpan(text: text, style: style);
  }
}
