import 'package:flutter/material.dart';

class SingleTextDialog extends StatefulWidget {
  SingleTextDialog({
    Key key,
    this.validator,
    this.decoration,
    this.initialValue,
    this.keyboardType,
  }) : super(key: key);

  final String Function(String) validator;
  final InputDecoration decoration;
  final String initialValue;
  final TextInputType keyboardType;

  @override
  _SingleTextDialogState createState() => _SingleTextDialogState();
}

class _SingleTextDialogState extends State<SingleTextDialog> {
  final textController = TextEditingController();
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Form(
          key: form,
          child: TextFormField(
            controller: textController,
            autofocus: true,
            onSaved: onSubmit,
            onFieldSubmitted: onSubmit,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            decoration: widget.decoration,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => onSubmit(null),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => onSubmit(textController.text),
          child: Text('確認'),
        ),
      ],
    );
  }

  void onSubmit(String value) {
    if (form.currentState.validate()) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    textController.text = widget.initialValue;
  }
}
