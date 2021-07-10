import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/translator.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({
    Key? key,
    required this.content,
    required this.onDelete,
  }) : super(key: key);

  final Widget content;
  final Future<void> Function(BuildContext) onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tt('delete_title')),
      content: SingleChildScrollView(child: content),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tt('cancel')),
        ),
        ElevatedButton(
          onPressed: () async {
            await onDelete(context);
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            primary: kNegativeColor,
            onPrimary: Colors.white,
          ),
          child: Text(tt('delete')),
        ),
      ],
    );
  }
}
