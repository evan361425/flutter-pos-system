import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/translator.dart';

class SingleTextDialog extends StatefulWidget {
  const SingleTextDialog({
    Key? key,
    this.validator,
    this.formatter,
    this.decoration,
    this.initialValue,
    this.keyboardType,
    this.selectAll = false,
    this.autofocus = true,
    this.header,
    this.title,
  }) : super(key: key);

  final String? Function(String?)? validator;
  final String? Function(String?)? formatter;
  final Widget? title;
  final InputDecoration? decoration;
  final String? initialValue;
  final TextInputType? keyboardType;
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
    final textField = TextFormField(
      key: const Key('text_dialog.text'),
      controller: textController,
      autofocus: widget.autofocus,
      onSaved: onSubmit,
      onFieldSubmitted: onSubmit,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      decoration: widget.decoration,
      textInputAction: TextInputAction.done,
    );

    return AlertDialog(
      title: widget.title,
      content: SingleChildScrollView(
        child: Column(children: [
          if (widget.header != null) widget.header!,
          Form(
            key: form,
            child: textField,
          )
        ]),
      ),
      actions: [
        PopButton(key: const Key('text_dialog.cancel'), title: S.btnCancel),
        FilledButton(
          key: const Key('text_dialog.confirm'),
          onPressed: () => onSubmit(textController.text),
          child: Text(S.btnConfirm),
        ),
      ],
    );
  }

  void onSubmit(String? value) {
    if (form.currentState!.validate()) {
      Navigator.of(context).pop(
        widget.formatter != null ? widget.formatter!(value) : value,
      );
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
