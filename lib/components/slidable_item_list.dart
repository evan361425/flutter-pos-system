import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/translator.dart';

class SlidableItemList<T, Action> extends StatelessWidget {
  final SlidableItemDelegate<T, Action> delegate;

  final bool scrollable;

  final String? hintText;

  const SlidableItemList({
    Key? key,
    required this.delegate,
    this.scrollable = true,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int index = 0;

    final child = Column(children: <Widget>[
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: HintText(hintText ?? S.totalCount(delegate.items.length)),
        ),
      ),
      for (final item in delegate.items)
        delegate.build(context, item, index: index++, theme: theme),
      const SizedBox(height: 4.0),
    ]);

    final groupChild = delegate.groupTag == null
        ? child
        : SlidableAutoCloseBehavior(child: child);

    return scrollable ? SingleChildScrollView(child: groupChild) : groupChild;
  }
}

class SlidableItemDelegate<T, U> {
  final List<T> items;

  /// Return value from navigator after delete
  final U deleteValue;

  final Future<void> Function(T) handleDelete;

  final Widget Function(BuildContext, int, T, VoidCallback) tileBuilder;

  final Widget Function(BuildContext, T)? warningContextBuilder;

  final Iterable<BottomSheetAction<U>> Function(T)? actionBuilder;

  final void Function(BuildContext, T)? handleTap;

  final void Function(T item, U action)? handleAction;

  final Object? groupTag;

  SlidableItemDelegate({
    required this.items,
    required this.deleteValue,
    required this.tileBuilder,
    this.groupTag,
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
    return Slidable(
      groupTag: groupTag,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            key: groupTag == null ? null : Key('slidable.$groupTag.$index'),
            label: S.btnDelete,
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: KIcons.delete,
            onPressed: (_) => DeleteDialog.show(
              context,
              deleteCallback: () => handleDelete(item),
              warningContent: warningContextBuilder == null
                  ? null
                  : warningContextBuilder!(context, item),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (handleTap != null) {
            handleTap!(context, item);
          }
        },
        onLongPress: () => showActions(context, item),
        child:
            tileBuilder(context, index, item, () => showActions(context, item)),
      ),
    );
  }

  Future<void> showActions(BuildContext context, T item) async {
    final customActions = actionBuilder == null
        ? const <BottomSheetAction>[]
        : actionBuilder!(item).toList();

    final result = await BottomSheetActions.withDelete<U>(
      context,
      actions: customActions.toList(),
      deleteValue: deleteValue,
      warningContent: warningContextBuilder == null
          ? null
          : warningContextBuilder!(context, item),
      deleteCallback: () => handleDelete(item),
    );

    if (result != null) {
      handleAction?.call(item, result);
    }
  }
}
