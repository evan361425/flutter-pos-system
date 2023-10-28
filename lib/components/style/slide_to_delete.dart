import 'package:flutter/material.dart';
import 'package:possystem/constants/icons.dart';

class SlideToDelete<T> extends StatelessWidget {
  final T item;

  final Widget child;

  final void Function()? onDismissed;

  final Future<bool?> Function(DismissDirection)? confirmDismiss;

  const SlideToDelete({
    Key? key,
    required this.item,
    required this.child,
    this.onDismissed,
    this.confirmDismiss,
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
      onDismissed: onDismissed == null ? null : (_) => onDismissed!(),
      confirmDismiss: confirmDismiss,
      child: child,
    );
  }
}
