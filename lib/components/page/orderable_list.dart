import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helper/custom_styles.dart';

abstract class OrderableList<T> extends StatefulWidget {
  OrderableList({
    Key? key,
    required this.items,
    required this.title,
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(KIcons.back),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                await handleSubmit();
                Navigator.of(context).pop();
              },
              child: Text('儲存')),
        ],
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(kSpacing0),
            child: Text(
              '總共 ${widget.items.length} 項',
              style: Theme.of(context).textTheme.muted,
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
    );
  }

  int get itemCount;

  Widget itemBuilder(BuildContext context, int index);

  Future<void> handleSubmit();
}

class OrderableListItem extends StatelessWidget {
  OrderableListItem({this.title, this.index, Key? key}) : super(key: key);

  final String? title;
  final int? index;

  Widget _builder(BuildContext context) {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ReorderableDelayedDragStartListener(
            index: index!,
            child: Padding(
              padding: const EdgeInsets.all(kSpacing3),
              child: Text(title!),
            ),
          ),
        ),
        ReorderableDragStartListener(
          index: index!,
          child: Padding(
            padding: const EdgeInsets.only(right: kSpacing3),
            child: Center(child: Icon(Icons.reorder_sharp)),
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
