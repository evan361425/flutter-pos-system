import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderActions extends StatelessWidget {
  const OrderActions({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, OrderActionTypes.pop_stash),
          child: Text('顯示最後一次點餐'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, OrderActionTypes.stash),
          child: Text('暫存本次點餐'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, OrderActionTypes.leave),
          child: Text('離開點餐頁面'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: Text('取消'),
      ),
    );
  }
}

enum OrderActionTypes {
  pop_stash,
  stash,
  leave,
}
