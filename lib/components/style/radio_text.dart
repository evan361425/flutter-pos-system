import 'package:flutter/material.dart';

class RadioText extends StatelessWidget {
  final bool isSelected;

  final String text;

  final bool isTogglable;

  final EdgeInsets margin;

  final void Function(bool isSelected) onChanged;

  const RadioText({
    Key? key,
    required this.isSelected,
    required this.text,
    required this.onChanged,
    this.isTogglable = false,
    this.margin = const EdgeInsets.symmetric(vertical: 4),
  }) : super(key: key);

  static Widget empty([String text = '']) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.primaryColor;
    final textColor = theme.colorScheme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onPrimary;

    return Container(
      margin: margin,
      constraints: const BoxConstraints(minWidth: 64.0),
      decoration: BoxDecoration(
        color: isSelected ? color : null,
        border: Border.all(
          color: isSelected ? color : const Color(0xDD000000),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: InkWell(
        onTap: () => !isSelected || isTogglable ? onChanged(!isSelected) : null,
        splashColor: color,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: isSelected ? TextStyle(color: textColor) : null,
          ),
        ),
      ),
    );
  }
}
