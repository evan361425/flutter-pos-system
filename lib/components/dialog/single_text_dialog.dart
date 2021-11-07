import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/translator.dart';

class SingleTextDialog extends StatefulWidget {
  const SingleTextDialog({
    Key? key,
    this.validator,
    this.decoration,
    this.initialValue,
    this.keyboardType,
    this.title,
  }) : super(key: key);

  final String? Function(String?)? validator;
  final Widget? title;
  final InputDecoration? decoration;
  final String? initialValue;
  final TextInputType? keyboardType;

  @override
  _SingleTextDialogState createState() => _SingleTextDialogState();
}

class _SingleTextDialogState extends State<SingleTextDialog> {
  late TextEditingController textController;
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: SingleChildScrollView(
        child: Form(
          key: form,
          child: TextFormField(
            key: const Key('text_dialog.text'),
            controller: textController,
            autofocus: true,
            onSaved: onSubmit,
            onFieldSubmitted: onSubmit,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            decoration: widget.decoration,
            textInputAction: TextInputAction.done,
          ),
        ),
      ),
      actions: [
        PopButton(key: const Key('text_dialog.cancel'), title: S.btnCancel),
        ElevatedButton(
          key: const Key('text_dialog.confirm'),
          onPressed: () => onSubmit(textController.text),
          child: Text(S.btnConfirm),
        ),
      ],
    );
  }

  void onSubmit(String? value) {
    if (form.currentState!.validate()) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.initialValue);
  }
}
