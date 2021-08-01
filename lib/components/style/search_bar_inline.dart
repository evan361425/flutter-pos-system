import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';

class SearchBarInline extends StatefulWidget {
  final String? text;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final void Function(BuildContext) onTap;

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
  _SearchBarInlineState createState() => _SearchBarInlineState();
}

class _SearchBarInlineState extends State<SearchBarInline> {
  late TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.subtitle1;
    final border = textTheme?.color == null
        ? null
        : OutlineInputBorder(
            borderSide: BorderSide(color: textTheme!.color!),
          );

    return TextField(
      readOnly: true,
      enableInteractiveSelection: false,
      controller: textController,
      onTap: () => widget.onTap(context),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: border,
        isDense: true,
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        focusedBorder: border,
        labelStyle: textTheme,
        prefixIcon: Icon(KIcons.search, color: textTheme?.color),
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    textController = TextEditingController(text: widget.text);
    super.initState();
  }
}
