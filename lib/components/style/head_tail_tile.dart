import 'package:flutter/material.dart';

class HeadTailTile extends StatelessWidget {
  final String head;

  final String? tail;

  final Widget? tailWidget;

  final Widget? subtitle;

  const HeadTailTile({super.key, required this.head, this.tail, this.tailWidget, this.subtitle})
    : assert(tailWidget != null || tail != null);

  @override
  Widget build(BuildContext context) {
    final child = Row(mainAxisAlignment: .spaceBetween, children: [Text(head), tailWidget ?? Text(tail!)]);
    return Padding(
      padding: const .only(left: 16.0, right: 24.0, top: 8.0, bottom: 8.0),
      child: subtitle == null ? child : Column(children: [child, subtitle!]),
    );
  }
}
