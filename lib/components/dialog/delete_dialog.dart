import 'package:flutter/material.dart';
import 'package:possystem/translator.dart';

class DeleteDialog extends StatelessWidget {
  final Widget content;

  const DeleteDialog({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(tt('delete_title')),
      content: SingleChildScrollView(child: content),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tt('cancel')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            primary: theme.errorColor,
            onPrimary: Colors.white,
          ),
          child: Text(tt('delete')),
        ),
      ],
    );
  }
}
