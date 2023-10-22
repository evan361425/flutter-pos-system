import 'package:flutter/material.dart';

class HeadTailTile extends StatelessWidget {
  final String head;

  final String tail;

  final Widget? subtitle;

  const HeadTailTile({
    Key? key,
    required this.head,
    required this.tail,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(head),
        Text(tail),
      ],
    );
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 16.0,
        end: 24.0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: subtitle == null ? child : Column(children: [child, subtitle!]),
    );
  }
}
