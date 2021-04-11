import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderActions extends StatelessWidget {
  const OrderActions({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {},
          child: Text('顯示最後一次點餐'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {},
          child: Text('暫存本次點餐'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            var count = 0;
            Navigator.of(context).popUntil((route) => count++ == 2);
          },
          child: Text('離開點餐頁面'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context, 'cancel'),
        child: Text('取消'),
      ),
    );
  }
}
