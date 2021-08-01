import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';

class SearchBarInline extends StatelessWidget {
  final String? text;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final Future<void> Function(BuildContext) onTap;
  static final textController = TextEditingController();

  const SearchBarInline({
    Key? key,
    this.text,
    this.errorText,
    this.labelText,
    this.hintText,
    this.helperText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    textController.text = text ?? '';
    final textTheme = Theme.of(context).textTheme.subtitle1;
    final border = textTheme?.color == null
        ? null
        : UnderlineInputBorder(
            borderSide: BorderSide(color: textTheme!.color!),
          );

    return TextField(
      readOnly: true,
      enableInteractiveSelection: false,
      controller: textController,
      onTap: () => onTap(context),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        focusedBorder: border,
        labelStyle: textTheme,
        prefixIcon: Icon(KIcons.search, color: textTheme?.color),
      ),
    );
  }
}
