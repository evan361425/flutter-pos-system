import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/translator.dart';

// use inherit objects to make your life better
class SlidableItemList<T> extends StatefulWidget {
  final Iterable<T> items;

  final Future<void> Function(BuildContext, T) handleDelete;
  final Widget Function(BuildContext, int, T) tileBuilder;
  final Widget Function(BuildContext, T)? warningContextBuilder;
  final void Function(BuildContext, T)? handleTap;
  final Iterable<BottomSheetAction> Function(T)? actionBuilder;

  const SlidableItemList({
    Key? key,
    required this.items,
    required this.tileBuilder,
    this.warningContextBuilder,
    required this.handleDelete,
    this.handleTap,
    this.actionBuilder,
  }) : super(key: key);

  @override
  SlidableItemListState<T> createState() => SlidableItemListState<T>();
}

class SlidableItemListState<T> extends State<SlidableItemList<T>> {
  final _slidableController = SlidableController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var count = 0;

    return Column(
      children: [
        for (var item in widget.items)
          _itemBuilder(
            item,
            theme: theme,
            index: count++,
          )
      ],
    );
  }

  Future<void> _handleDelete(T item) async {
    if (widget.warningContextBuilder != null) {
      final isConfirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => DeleteDialog(
          content: widget.warningContextBuilder!(context, item),
        ),
      );

      if (isConfirmed != true) {
        return;
      }
    }

    await widget.handleDelete(context, item);

    showSuccessSnackbar(context, tt('success'));
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

  Widget _itemBuilder(T item, {required ThemeData theme, required int index}) {
    return Card(
      shape: RoundedRectangleBorder(),
      margin: const EdgeInsets.all(0),
      child: Slidable(
        controller: _slidableController,
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            color: theme.errorColor,
            caption: tt('delete'),
            icon: KIcons.delete,
            onTap: () => _handleDelete(item),
          ),
        ],
        child: GestureDetector(
          onTap: () {
            if (_checkPanelStatus() && widget.handleTap != null) {
              widget.handleTap!(context, item);
            }
          },
          onLongPress: () => showActions(item),
          child: widget.tileBuilder(context, index, item),
        ),
      ),
    );
  }

  Future<void> showActions(T item) async {
    final theme = Theme.of(context);
    final custom = widget.actionBuilder == null
        ? const <BottomSheetAction>[]
        : widget.actionBuilder!(item);

    final result = await showCircularBottomSheet<bool>(
      context,
      actions: <BottomSheetAction>[
        ...custom,
        BottomSheetAction(
          title: Text(tt('delete')),
          leading: Icon(KIcons.delete, color: theme.errorColor),
          onTap: (context) => Navigator.of(context).pop(false),
        ),
      ],
    );

    if (result == false) {
      await _handleDelete(item);
    }
  }
}
