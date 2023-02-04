import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/translator.dart';

class ReorderableScaffold<T> extends StatelessWidget {
  final String? title;

  final List<T> items;

  final Future<void> Function(List<T>) handleSubmit;

  const ReorderableScaffold({
    Key? key,
    required this.items,
    this.title,
    required this.handleSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: [
          TextButton(
            key: const Key('reorder.save'),
            onPressed: () async {
              await handleSubmit(items);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(S.btnSave),
          ),
        ],
        title: title == null ? null : Text(title!),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(kSpacing0),
              child: HintText(S.totalCount(items.length)),
            ),
          ),
          Expanded(
            child: _OrderableList(items: items),
          ),
        ],
      ),
    );
  }
}

class _OrderableList<T> extends StatefulWidget {
  final List<T> items;

  const _OrderableList({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  State<_OrderableList> createState() => _OrderableListState();
}

class _OrderableListState extends State<_OrderableList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableList(
      itemCount: widget.items.length,
      onReorder: _handleReorder,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items[index];

        return _ReorderableListItem(
          key: ValueKey(item.index),
          index: index,
          title: item.name,
        );
      },
    );
  }

  bool _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final draggedItem = widget.items.removeAt(oldIndex);
      widget.items.insert(newIndex, draggedItem);
    });

    return true;
  }
}

class _ReorderableListItem extends StatelessWidget {
  final String? title;

  final int? index;

  const _ReorderableListItem({this.title, this.index, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('reorder.$index'),
      shape: const RoundedRectangleBorder(),
      margin: const EdgeInsets.all(0.5),
      child: Row(children: [
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
          child: const Padding(
            padding: EdgeInsets.only(right: kSpacing3),
            child: Center(child: Icon(Icons.reorder_sharp)),
          ),
        ),
      ]),
    );
  }
}
