import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';

class SingleTextDialog extends StatefulWidget {
  const SingleTextDialog({
    super.key,
    this.validator,
    this.formatter,
    this.hints,
    this.decoration,
    this.initialValue,
    this.keyboardType,
    this.maxLength,
    this.selectAll = false,
    this.autofocus = true,
    this.header,
    this.title,
  });

  final String? Function(String?)? validator;
  final String? Function(String?)? formatter;
  final Iterable<String>? hints;
  final Widget? title;
  final InputDecoration? decoration;
  final String? initialValue;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool selectAll;
  final bool autofocus;

  /// Widget above TextField
  final Widget? header;

  @override
  State<SingleTextDialog> createState() => _SingleTextDialogState();
}

class _SingleTextDialogState extends State<SingleTextDialog> {
  late TextEditingController textController;
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);
    final textField = TextFormField(
      key: const Key('text_dialog.text'),
      controller: textController,
      autofocus: widget.autofocus,
      autofillHints: widget.hints,
      onSaved: onSubmit,
      onFieldSubmitted: onSubmit,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      decoration: widget.decoration,
      maxLength: widget.maxLength,
      textInputAction: TextInputAction.done,
    );

    return AlertDialog(
      title: widget.title,
      scrollable: true,
      content: Column(children: [
        if (widget.header != null) widget.header!,
        Form(
          key: form,
          child: textField,
        )
      ]),
      actions: [
        PopButton(
          key: const Key('text_dialog.cancel'),
          title: local.cancelButtonLabel,
        ),
        FilledButton(
          key: const Key('text_dialog.confirm'),
          onPressed: () => onSubmit(textController.text),
          child: Text(local.okButtonLabel),
        ),
      ],
    );
  }

  void onSubmit(String? value) {
    if (form.currentState!.validate()) {
      Navigator.of(context).pop(widget.formatter?.call(value) ?? value);
    }
  }

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.initialValue);
    if (widget.selectAll && widget.initialValue != null) {
      textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.initialValue!.length,
      );
    }
  }
}
