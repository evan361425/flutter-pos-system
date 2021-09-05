import 'package:flutter/material.dart';

class HintText extends StatelessWidget {
  final String text;

  final TextOverflow? overflow;

  const HintText(this.text, {Key? key, this.overflow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.caption!.copyWith(
      color: theme.hintColor,
      inherit: true,
    );

    return Text(text, style: style, overflow: overflow);
  }

  static TextSpan inSpan(BuildContext context, String text) {
    final theme = Theme.of(context);
    final style = theme.textTheme.caption!.copyWith(
      color: theme.hintColor,
      inherit: true,
    );

    return TextSpan(text: text, style: style);
  }
}
