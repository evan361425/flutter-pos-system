import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/slide_to_delete.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/translator.dart';

class SlidableItemList<T, Action> extends StatelessWidget {
  final SlidableItemDelegate<T, Action> delegate;
  final String? hintText;
  final Widget? leading;
  final Widget? action;

  const SlidableItemList({
    super.key,
    required this.delegate,
    this.hintText,
    this.leading,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: kTopSpacing, bottom: kFABSpacing),
        child: Column(children: <Widget>[
          if (leading != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
              child: leading!,
            ),
          Row(children: [
            if (hintText != '')
              Expanded(child: Center(child: HintText(hintText ?? S.totalCount(delegate.items.length)))),
            if (action != null)
              Padding(
                padding: const EdgeInsets.only(right: kHorizontalSpacing),
                child: action,
              ),
          ]),
          const SizedBox(height: kInternalSpacing),
          for (final widget in delegate.items.mapIndexed(
            (index, item) => delegate.build(item, index),
          ))
            widget,
        ]),
      ),
    );
  }
}

typedef ActorBuilder = void Function([BuildContext?]) Function(BuildContext context);

class SlidableItemDelegate<T, U> {
  final List<T> items;

  final Widget Function(T item, int index, ActorBuilder actorBuilder) tileBuilder;

  final Future<void> Function(T item) handleDelete;

  /// When set the function, it will call before deletion
  final Widget Function(BuildContext context, T item)? warningContentBuilder;

  /// Build the actions without deletion.
  final Iterable<BottomSheetAction<U>> Function(T item)? actionBuilder;

  /// You should ignore deletion which will be handled.
  final void Function(T item, U action)? handleAction;

  /// Required when using [showActions].
  final U? deleteValue;

  final bool disableSlide;

  SlidableItemDelegate(
      {required this.items,
      required this.tileBuilder,
      required this.handleDelete,
      this.deleteValue,
      this.warningContentBuilder,
      this.actionBuilder,
      this.handleAction,
      this.disableSlide = false});

  Widget build(T item, int index) {
    final child = tileBuilder(
      item,
      index,
      (BuildContext context) => ([BuildContext? ctx]) => showActions(ctx ?? context, item),
    );
    if (disableSlide) {
      return child;
    }

    return SlideToDelete(
      item: item,
      deleteCallback: () => handleDelete(item),
      warningContentBuilder: (ctx) => warningContentBuilder?.call(ctx, item),
      child: child,
    );
  }

  Future<void> showActions(BuildContext context, T item) async {
    assert(deleteValue != null, "deleteValue should be set when using actions");

    final customActions = actionBuilder == null ? <BottomSheetAction<U?>>[] : actionBuilder!(item).toList();

    final result = await BottomSheetActions.withDelete<U?>(
      context,
      actions: customActions.toList(),
      deleteValue: deleteValue,
      warningContent: warningContentBuilder == null ? null : warningContentBuilder!(context, item),
      deleteCallback: () => handleDelete(item),
    );

    if (result != null && handleAction != null) {
      handleAction!(item, result);
    }
  }
}
