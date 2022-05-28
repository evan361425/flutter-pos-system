import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';

class SearchBarInline extends StatelessWidget {
  final String? text;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final void Function(BuildContext) onTap;
  final TextEditingController textController;

  SearchBarInline({
    Key? key,
    this.text,
    this.errorText,
    this.labelText,
    this.hintText,
    this.helperText,
    required this.onTap,
  })  : textController = TextEditingController(text: text),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.bodyMedium;
    final border = textTheme?.color == null
        ? null
        : OutlineInputBorder(
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
        border: border,
        isDense: true,
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
