import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/translator.dart';

class SlidableItemList<T, Action> extends StatelessWidget {
  final SlidableItemDelegate<T, Action> delegate;

  const SlidableItemList({
    Key? key,
    required this.delegate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int index = 0;

    return SingleChildScrollView(
      child: Column(children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: HintText(S.totalCount(delegate.items.length)),
          ),
        ),
        for (final item in delegate.items)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2.0),
            child: delegate.build(context, item, index: index++, theme: theme),
          ),
      ]),
    );
  }
}

class SliverSlidableItemBuilder extends SliverChildDelegate {
  final SlidableItemDelegate delegate;

  const SliverSlidableItemBuilder(this.delegate);

  @override
  Widget? build(BuildContext context, int index) {
    if (index < 0 || index >= delegate.items.length) return null;

    final item = delegate.items[index];
    final theme = Theme.of(context);

    return KeyedSubtree(
      child: AutomaticKeepAlive(
        child: IndexedSemantics(
          index: index,
          child: RepaintBoundary(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              child: delegate.build(context, item, index: index, theme: theme),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverChildDelegate oldDelegate) => true;

  @override
  int? get estimatedChildCount => delegate.items.length;
}

class SlidableItemDelegate<T, U> {
  final List<T> items;

  /// Return value from navigator after delete
  final U deleteValue;

  final Future<void> Function(T) handleDelete;

  final Widget Function(BuildContext, int, T, SlidableItemDelegate) tileBuilder;

  final Widget Function(BuildContext, T)? warningContextBuilder;

  final Iterable<BottomSheetAction<U>> Function(T)? actionBuilder;

  final void Function(BuildContext, T)? handleTap;

  final void Function(U? action)? handleAction;

  final _slidableController = SlidableController();

  SlidableItemDelegate({
    required this.items,
    required this.deleteValue,
    required this.tileBuilder,
    this.warningContextBuilder,
    this.actionBuilder,
    this.handleAction,
    required this.handleDelete,
    this.handleTap,
  });

  Widget build(
    BuildContext context,
    T item, {
    required int index,
    required ThemeData theme,
  }) {
    return Card(
      shape: const RoundedRectangleBorder(),
      margin: const EdgeInsets.all(0),
      child: Slidable(
        controller: _slidableController,
        actionPane: const SlidableDrawerActionPane(),
        secondaryActions: <Widget>[
          IconSlideAction(
            color: theme.errorColor,
            caption: S.btnDelete,
            icon: KIcons.delete,
            onTap: () => DeleteDialog.show(
              context,
              deleteCallback: () => handleDelete(item),
              warningContent: warningContextBuilder == null
                  ? null
                  : warningContextBuilder!(context, item),
            ),
          ),
        ],
        child: GestureDetector(
          onTap: () {
            if (_checkPanelStatus() && handleTap != null) {
              handleTap!(context, item);
            }
          },
          onLongPress: () => showActions(context, item),
          child: tileBuilder(context, index, item, this),
        ),
      ),
    );
  }

  Future<void> showActions(BuildContext context, T item) async {
    final customActions = actionBuilder == null
        ? const <BottomSheetAction>[]
        : actionBuilder!(item).toList();

    await BottomSheetActions.withDelete<U>(
      context,
      actions: customActions.toList(),
      deleteValue: deleteValue,
      warningContent: warningContextBuilder == null
          ? null
          : warningContextBuilder!(context, item),
      deleteCallback: () => handleDelete(item),
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
}
