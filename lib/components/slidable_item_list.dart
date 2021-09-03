import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/translator.dart';

// use inherit objects to make your life better
class SlidableItemList<T, Action> extends StatefulWidget {
  final Iterable<T> items;

  /// Show bottom actions of deletions
  final Action? deleteValue;
  final Future<void> Function(BuildContext, T) handleDelete;
  final Widget Function(BuildContext, int, T) tileBuilder;
  final Widget Function(BuildContext, T)? warningContextBuilder;
  final void Function(BuildContext, T)? handleTap;
  final Iterable<BottomSheetAction<Action>> Function(T)? actionBuilder;
  final void Function(Action? action)? handleAction;

  const SlidableItemList({
    Key? key,
    required this.items,
    this.deleteValue,
    required this.tileBuilder,
    this.warningContextBuilder,
    this.actionBuilder,
    this.handleAction,
    required this.handleDelete,
    this.handleTap,
  }) : super(key: key);

  @override
  SlidableItemListState<T, Action> createState() =>
      SlidableItemListState<T, Action>();
}

class SlidableItemListState<T, Action>
    extends State<SlidableItemList<T, Action>> {
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

  Future<void> showActions(T item) async {
    final customActions = widget.actionBuilder == null
        ? const <BottomSheetAction<Action>>[]
        : widget.actionBuilder!(item).toList();

    if (widget.deleteValue == null) {
      // no need to do things if no action given
      if (customActions.isNotEmpty) {
        final result = await showCircularBottomSheet<Action>(
          context,
          actions: customActions,
        );

        if (widget.handleAction != null) {
          widget.handleAction!(result);
        }
      }
      return;
    }

    await BottomSheetActions.withDelete<Action>(
      context,
      actions: customActions.toList(),
      deleteValue: widget.deleteValue!,
      warningContent: widget.warningContextBuilder!(context, item),
      deleteCallback: () => widget.handleDelete(context, item),
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
            onTap: () => DeleteDialog.show(
              context,
              deleteCallback: () => widget.handleDelete(context, item),
              warningContent: widget.warningContextBuilder == null
                  ? null
                  : widget.warningContextBuilder!(context, item),
            ),
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
}
