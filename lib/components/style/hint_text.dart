import 'package:flutter/material.dart';

class HintText extends StatelessWidget {
  final String text;
  const HintText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.inputDecorationTheme.helperStyle ??
        theme.textTheme.caption!.copyWith(color: theme.hintColor);

    return Text(text, style: style);
  }
}
