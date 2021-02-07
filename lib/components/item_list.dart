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
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) =>
          _itemBuilder(context, items[index]),
    );
  }

  Widget _itemBuilder(BuildContext context, T item) {
    return Card(
      shape: RoundedRectangleBorder(),
      margin: EdgeInsets.all(0),
      child: Slidable(
        controller: _slidableController,
        actionPane: SlidableDrawerActionPane(),
        child: itemTile(context, item),
        secondaryActions: <Widget>[
          IconSlideAction(
            color: colorNegative,
            caption: Local.of(context).t('delete'),
            icon: Icons.delete,
            onTap: () => onDelete(item),
          ),
        ],
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

  // Abstract Methods

  Widget itemTile(BuildContext context, T item);

  void onDelete(T item);
}
