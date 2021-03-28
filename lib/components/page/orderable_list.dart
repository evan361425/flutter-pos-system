import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  bool _reorderCallback(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
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
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back_ios_sharp),
        ),
        trailing: isSaving
            ? CircularProgressIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await onSubmit();
                  Navigator.of(context).pop();
                },
                child: Text('儲存'),
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
              child: ReorderableList(
                itemCount: itemCount,
                itemBuilder: itemBuilder,
                onReorder: _reorderCallback,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get itemCount;

  Widget itemBuilder(BuildContext context, int index);

  Future<void> onSubmit();
}

class OrderableListItem extends StatelessWidget {
  OrderableListItem({this.title, this.index, Key key}) : super(key: key);

  final String title;
  final int index;

  Widget _builder(BuildContext context) {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ReorderableDelayedDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.all(kPadding),
              child: Text(title),
            ),
          ),
        ),
        ReorderableDragStartListener(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(right: kPadding),
            child: Center(child: Icon(Icons.reorder)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(),
      margin: const EdgeInsets.all(0.5),
      child: _builder(context),
    );
  }
}
