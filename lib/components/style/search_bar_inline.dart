import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';

class SearchBarInline extends StatelessWidget {
  final String? text;
  final String? Function(String?)? validator;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final bool autofocus;
  final void Function(BuildContext) onTap;

  /// using controller for dynamically change the initialValue
  final TextEditingController textController;

  SearchBarInline({
    Key? key,
    this.text,
    this.validator,
    this.labelText,
    this.hintText,
    this.helperText,
    this.autofocus = false,
    required this.onTap,
  })  : textController = TextEditingController(text: text),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: TextFormField(
        readOnly: true,
        enableInteractiveSelection: false,
        controller: textController,
        onTap: () => onTap(context),
        textInputAction: TextInputAction.search,
        validator: validator,
        autofocus: autofocus,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: const OutlineInputBorder(borderSide: BorderSide()),
          isDense: true,
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
          prefixIcon: const Icon(KIcons.search),
        ),
      ),
    );
  }
}
