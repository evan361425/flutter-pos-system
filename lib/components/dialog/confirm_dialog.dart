import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/translator.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    Key? key,
    required this.title,
    this.content,
  }) : super(key: key);

  final String title;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content == null ? null : SingleChildScrollView(child: content),
      actions: <Widget>[
        PopButton(title: tt('cancel')),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(tt('confirm')),
        ),
      ],
    );
  }
}
