import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/components/dialog/responsive_dialog.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/translator.dart';

class ReorderableScaffold<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ResponsiveDialog(
      title: Text(title),
      scrollable: false,
      action: TextButton(
        key: const Key('reorder.save'),
        onPressed: () async {
          await handleSubmit(items);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Text(MaterialLocalizations.of(context).saveButtonLabel),
      ),
      content: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const SizedBox(height: kTopSpacing),
        Center(child: HintText(S.totalCount(items.length))),
        const SizedBox(height: kInternalSpacing),
        Expanded(child: MyReorderableList(items: items)),
      ]),
    );
  }
}

class MyReorderableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, Widget toggler)? itemBuilder;

  const MyReorderableList({
    super.key,
    required this.items,
    this.itemBuilder,
  });

  @override
  State<MyReorderableList<T>> createState() => _MyReorderableListState<T>();
}

class _MyReorderableListState<T> extends State<MyReorderableList<T>> {
  @override
  Widget build(BuildContext context) {
    Widget child = ReorderableList(
      itemCount: widget.items.length,
      onReorder: _handleReorder,
      onReorderStart: (int index) => HapticFeedback.lightImpact(),
      onReorderEnd: (int index) => HapticFeedback.lightImpact(),
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items[index];
        final toggler = ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.reorder_outlined),
        );

        // delayed drag let it able to scroll
        return ReorderableDelayedDragStartListener(
          key: Key('reorder.$index'), // required for reorder
          index: index,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Material(
              elevation: 1.0,
              child: widget.itemBuilder != null
                  ? widget.itemBuilder!(context, item, toggler)
                  : ListTile(
                      title: Text((item as dynamic).name),
                      trailing: toggler,
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
    return child;
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
