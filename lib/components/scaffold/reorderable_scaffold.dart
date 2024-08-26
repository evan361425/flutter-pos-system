import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/translator.dart';

class ReorderableScaffold<T extends ModelOrderable> extends StatefulWidget {
  final String title;

  final List<T> items;

  final Future<void> Function(List<T>) handleSubmit;

  const ReorderableScaffold({
    super.key,
    required this.items,
    required this.title,
    required this.handleSubmit,
  });

  @override
  State<ReorderableScaffold<T>> createState() => _ReorderableScaffoldState<T>();
}

class _ReorderableScaffoldState<T extends ModelOrderable> extends State<ReorderableScaffold<T>> {
  @override
  Widget build(BuildContext context) {
    Widget child = ReorderableList(
      itemCount: widget.items.length,
      onReorder: _handleReorder,
      onReorderStart: (int index) => HapticFeedback.lightImpact(),
      onReorderEnd: (int index) => HapticFeedback.lightImpact(),
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items[index];

        // delayed drag let it able to scroll
        return ReorderableDelayedDragStartListener(
          key: Key('reorder.$index'), // required for reorder
          index: index,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Material(
              elevation: 1.0,
              child: ListTile(
                title: Text(item.name),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.reorder_outlined),
                ),
              ),
            ),
          ),
        );
      },
    );
    final size = MediaQuery.sizeOf(context);
    if (size.width > Breakpoint.medium.max) {
      child = SizedBox(
        width: Breakpoint.compact.max,
        child: child,
      );
    }
    return ResponsiveDialog(
      title: Text(widget.title),
      scrollable: false,
      action: TextButton(
        key: const Key('reorder.save'),
        onPressed: () async {
          await widget.handleSubmit(widget.items);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Text(MaterialLocalizations.of(context).saveButtonLabel),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: kTopSpacing, bottom: kInternalSpacing),
              child: HintText(S.totalCount(widget.items.length)),
            ),
          ),
          Expanded(child: child),
        ],
      ),
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
