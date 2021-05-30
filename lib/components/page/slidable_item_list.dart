import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/localizations.dart';

// use inherit objects to make your life better
class SlidableItemList<T> extends StatefulWidget {
  const SlidableItemList({
    Key? key,
    required this.items,
    required this.onDelete,
    required this.tileBuilder,
    required this.warningContext,
    required this.onTap,
  }) : super(key: key);

  final List<T>? items;
  final Future<void> Function(BuildContext, T) onDelete;
  final Widget Function(BuildContext, T) tileBuilder;
  final Widget Function(BuildContext, T) warningContext;
  final void Function(BuildContext, T) onTap;

  @override
  _SlidableItemListState<T> createState() => _SlidableItemListState<T>();
}

class _SlidableItemListState<T> extends State<SlidableItemList<T>> {
  final _slidableController = SlidableController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (var item in widget.items!) _itemBuilder(context, item)],
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
            caption: Local.of(context)!.t('delete'),
            icon: KIcons.delete,
            onTap: () => _showDeleteDialog(context, item),
          ),
        ],
        child: GestureDetector(
          onTap: () {
            if (_checkPanelStatus()) {
              widget.onTap(context, item);
            }
          },
          child: widget.tileBuilder(context, item),
        ),
      ),
    );
  }

  /// If there is any action panel opening, close it
  bool _checkPanelStatus() {
    if (_slidableController.activeState != null) {
      _slidableController.activeState!.close();
      return false;
    } else {
      return true;
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, T item) {
    return showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return DeleteDialog(
          content: widget.warningContext(context, item),
          onDelete: (BuildContext context) => widget.onDelete(context, item),
        );
      },
    );
  }
}
