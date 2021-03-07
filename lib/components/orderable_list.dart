import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart' as rl;
import 'package:possystem/constants/constant.dart';

abstract class OrderableList<T> extends StatefulWidget {
  OrderableList({
    Key key,
    @required this.items,
    @required this.title,
  }) : super(key: key);

  final String title;

  final List<T> items;
}

abstract class OrderableListState<T, U> extends State<OrderableList<T>> {
  bool isSaving = false;

  bool _reorderCallback(Key oldKey, Key newKey) {
    final oldIndex = indexOfKey(oldKey is ValueKey ? oldKey.value : 0);
    final newIndex = indexOfKey(newKey is ValueKey ? newKey.value : 0);

    setState(() {
      final draggedItem = widget.items.removeAt(oldIndex);
      widget.items.insert(newIndex, draggedItem);
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(Icons.arrow_back_ios_sharp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        trailing: isSaving
            ? CircularProgressIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text('儲存'),
                onPressed: onSubmit,
              ),
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(kPadding / 4),
              child: Text(
                '總共 ${widget.items.length} 項',
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Expanded(
              child: rl.ReorderableList(
                onReorder: _reorderCallback,
                child: listWithScrollableView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listWithScrollableView();

  int indexOfKey(U key);

  Future<void> onSubmit();
}

class OrderableListItem<T> extends StatelessWidget {
  OrderableListItem({this.title, this.keyValue});

  final String title;
  final T keyValue;

  Widget _builder(BuildContext context, rl.ReorderableItemState state) {
    final color = state == rl.ReorderableItemState.dragProxy ||
            state == rl.ReorderableItemState.dragProxyFinished
        ? Theme.of(context).cardColor.withAlpha(224)
        : null;

    return Opacity(
      // hide content for placeholder
      opacity: state == rl.ReorderableItemState.placeholder ? 0.0 : 1.0,
      child: Card(
        shape: const RoundedRectangleBorder(),
        margin: const EdgeInsets.all(0.5),
        color: color,
        // shadowColor: Theme.of(context).primaryColor,
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: rl.DelayedReorderableListener(
                child: Padding(
                  padding: const EdgeInsets.all(kPadding),
                  child: Text(title),
                ),
                delay: Duration(milliseconds: 300),
              ),
            ),
            rl.ReorderableListener(
              child: Padding(
                padding: const EdgeInsets.only(right: kPadding),
                child: Center(child: Icon(Icons.reorder)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return rl.ReorderableItem(
        key: ValueKey<T>(keyValue), childBuilder: _builder);
  }
}
