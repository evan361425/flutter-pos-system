import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';

class SearchBarInline extends StatelessWidget {
  final String? text;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function() onTap;

  /// using controller for dynamically change the initialValue
  final TextEditingController textController;

  SearchBarInline({
    super.key,
    this.text,
    this.validator,
    this.labelText,
    this.hintText,
    required this.onTap,
  }) : textController = TextEditingController(text: text);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: TextFormField(
        readOnly: true,
        enableInteractiveSelection: false,
        controller: textController,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: const OutlineInputBorder(borderSide: BorderSide()),
          isDense: true,
          labelText: labelText,
          hintText: hintText,
          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
          errorMaxLines: 2,
          prefixIcon: const Icon(KIcons.search),
        ),
      ),
    );
  }
}
