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

  const ReorderableScaffold({super.key, required this.items, required this.title, required this.handleSubmit});

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
      content: Column(
        crossAxisAlignment: .end,
        children: [
          const SizedBox(height: kTopSpacing),
          Center(child: HintText(S.totalCount(items.length))),
          const SizedBox(height: kInternalSpacing),
          Expanded(child: MyReorderableList(items: items)),
        ],
      ),
    );
  }
}

class MyReorderableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, Widget toggler)? itemBuilder;

  final Widget Function(BuildContext context, T item, Widget toggler)? itemWhenDraggingBuilder;

  final VoidCallback? onReorder;

  final EdgeInsetsGeometry? padding;

  final Icon toggler;

  final Color? materialColor;

  final TextStyle? materialTextStyle;

  const MyReorderableList({
    super.key,
    required this.items,
    this.itemBuilder,
    this.itemWhenDraggingBuilder,
    this.onReorder,
    this.padding,
    this.materialColor,
    this.materialTextStyle,
    this.toggler = const Icon(Icons.reorder_outlined),
  });

  @override
  State<MyReorderableList<T>> createState() => _MyReorderableListState<T>();
}

class _MyReorderableListState<T> extends State<MyReorderableList<T>> {
  @override
  Widget build(BuildContext context) {
    Widget child = ReorderableList(
      padding: widget.padding,
      onReorder: _handleReorder,
      onReorderStart: (int index) => HapticFeedback.lightImpact(),
      onReorderEnd: (int index) => HapticFeedback.lightImpact(),
      prototypeItem: widget.itemBuilder != null
          ? null
          : const Padding(
              padding: .symmetric(vertical: 1.0),
              child: ListTile(title: Text('test')),
            ),
      itemCount: widget.items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = widget.items[index];
        final toggler = ReorderableDragStartListener(index: index, child: widget.toggler);

        // delayed drag let it able to scroll
        return ReorderableDelayedDragStartListener(
          key: Key('reorder.$index'), // required for reorder
          index: index,
          child: widget.itemBuilder != null
              ? widget.itemBuilder!(context, item, toggler)
              : Padding(
                  padding: const .symmetric(vertical: 1.0),
                  child: Material(
                    elevation: 1.0,
                    color: widget.materialColor,
                    textStyle: widget.materialTextStyle,
                    child: ListTile(title: Text((item as dynamic).name), trailing: toggler),
                  ),
                ),
        );
      },
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        final item = widget.items[index];
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return Material(
              color: widget.materialColor,
              textStyle: widget.materialTextStyle,
              elevation: 6.0,
              child: widget.itemWhenDraggingBuilder != null
                  ? widget.itemWhenDraggingBuilder!(context, item, widget.toggler)
                  : ListTile(title: Text((item as dynamic).name), trailing: widget.toggler),
            );
          },
          child: child,
        );
      },
    );
    final size = MediaQuery.sizeOf(context);
    if (size.width > Breakpoint.medium.max) {
      child = SizedBox(width: Breakpoint.compact.max, child: child);
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
    widget.onReorder?.call();

    return true;
  }
}
