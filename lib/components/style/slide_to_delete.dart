import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/constants/icons.dart';

class SlideToDelete<T> extends StatelessWidget {
  final T item;

  final Widget child;

  final Future<void> Function() deleteCallback;

  final Widget? Function(BuildContext context)? warningContentBuilder;

  const SlideToDelete({
    Key? key,
    required this.item,
    required this.child,
    required this.deleteCallback,
    this.warningContentBuilder,
  }) : super(key: key);

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
      confirmDismiss: warningContentBuilder == null
          ? null
          : (direction) => DeleteDialog.show(
                context,
                deleteCallback: () => Future.value(),
                warningContent: warningContentBuilder!(context),
              ),
      child: child,
    );
  }
}
