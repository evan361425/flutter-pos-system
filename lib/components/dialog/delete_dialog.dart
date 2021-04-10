import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({
    Key key,
    @required this.content,
    @required this.onDelete,
  }) : super(key: key);

  final Widget content;
  final Function(BuildContext) onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('確認刪除通知'),
      content: SingleChildScrollView(
        child: content,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            onDelete(context);
            Navigator.of(context).pop(true);
          },
          child: Text('刪除', style: TextStyle(color: kNegativeColor)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消'),
        ),
      ],
    );
  }
}
