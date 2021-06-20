import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/model.dart';

// use inherit objects to make your life better
class SlidableItemList<T extends Model> extends StatefulWidget {
  final List<T>? items;

  final Future<void> Function(BuildContext, T)? handleDelete;
  final Widget Function(BuildContext, T) tileBuilder;
  final Widget Function(BuildContext, T) warningContextBuilder;
  final void Function(BuildContext, T) handleTap;
  final Iterable<Widget> Function(BuildContext, T)? actionBuilder;

  const SlidableItemList({
    Key? key,
    required this.items,
    required this.tileBuilder,
    required this.warningContextBuilder,
    this.handleDelete,
    required this.handleTap,
    this.actionBuilder,
  }) : super(key: key);

  @override
  _SlidableItemListState<T> createState() => _SlidableItemListState<T>();
}

class _SlidableItemListState<T extends Model>
    extends State<SlidableItemList<T>> {
  final _slidableController = SlidableController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (var item in widget.items!) _itemBuilder(item)],
    );
  }

  Future<void> _showDeleteDialog(T item) {
    return showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return DeleteDialog(
          content: widget.warningContextBuilder(context, item),
          onDelete: (BuildContext context) async {
            await item.remove();
            if (widget.handleDelete != null) {
              await widget.handleDelete!(context, item);
            }
          },
        );
      },
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

  Widget _itemBuilder(T item) {
    return Card(
      shape: RoundedRectangleBorder(),
      margin: EdgeInsets.all(0),
      child: Slidable(
        controller: _slidableController,
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            color: kNegativeColor,
            caption: '刪除',
            icon: KIcons.delete,
            onTap: () => _showDeleteDialog(item),
          ),
        ],
        child: GestureDetector(
          onTap: () {
            if (_checkPanelStatus()) {
              widget.handleTap(context, item);
            }
          },
          onLongPress: () => _handleLongPress(item),
          child: widget.tileBuilder(context, item),
        ),
      ),
    );
  }

  void _handleLongPress(T item) {
    final custom = widget.actionBuilder == null
        ? const <Widget>[]
        : widget.actionBuilder!(context, item);

    showCircularBottomSheet(
      context,
      useRootNavigator: false,
      actions: <Widget>[
        ...custom,
        ListTile(
          title: Text('刪除'),
          leading: Icon(KIcons.delete, color: kNegativeColor),
          onTap: () async {
            // pop off sheet
            Navigator.of(context).pop();
            await _showDeleteDialog(item);
          },
        ),
      ],
    );
  }
}
