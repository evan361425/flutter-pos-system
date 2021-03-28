import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/localizations.dart';

// use inherit objects to make your life better
abstract class ItemList<T> extends StatelessWidget {
  final List<T> items;
  final SlidableController _slidableController = SlidableController();

  ItemList(this.items, {key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (var item in items) _itemBuilder(context, item)],
    );
  }

  Widget _itemBuilder(BuildContext context, T item) {
    return Card(
      shape: RoundedRectangleBorder(),
      margin: EdgeInsets.all(0),
      child: Slidable(
        controller: _slidableController,
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            color: kNegativeColor,
            caption: Local.of(context).t('delete'),
            icon: Icons.delete,
            onTap: () => showDeleteDialog(context, item),
          ),
        ],
        child: itemTile(context, item),
      ),
    );
  }

  /// If there is any action panel opening, close it
  /// Do things after [shouldProcess] return true;
  bool shouldProcess() {
    if (_slidableController.activeState == null) {
      return true;
    } else {
      _slidableController.activeState.close();
      return false;
    }
  }

  Future<void> showDeleteDialog(BuildContext context, T item) {
    return showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認刪除通知'),
          content: SingleChildScrollView(
            child: deleteWarnContext(context),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                onDelete(context, item);
                Navigator.of(context).pop();
              },
              child: Text('刪除', style: TextStyle(color: kNegativeColor)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('取消'),
            ),
          ],
        );
      },
    );
  }

  // Abstract Methods

  Widget itemTile(BuildContext context, T item);

  void onDelete(BuildContext context, T item);

  Widget deleteWarnContext(BuildContext context) {
    return Text('若刪除，將無法復原本動作');
  }
}
