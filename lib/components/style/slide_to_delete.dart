import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/constants/icons.dart';

class SlideToDelete<T> extends StatelessWidget {
  final T item;

  final Widget child;

  final Future<void> Function() deleteCallback;

  final Widget? Function(BuildContext context)? warningContentBuilder;

  final Widget? warningContent;

  const SlideToDelete({
    super.key,
    required this.item,
    required this.child,
    required this.deleteCallback,
    this.warningContentBuilder,
    this.warningContent,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey(item),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        color: const Color(0xFFC62828),
        child: const Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(KIcons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => deleteCallback(),
      confirmDismiss: warningContent == null && warningContentBuilder == null
          ? null
          : (direction) => DeleteDialog.show(
                context,
                deleteCallback: deleteCallback,
                warningContent: warningContent ?? warningContentBuilder!(context),
              ),
      child: child,
    );
  }
}
