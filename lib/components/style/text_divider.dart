import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class TextDivider extends StatelessWidget {
  final String label;

  const TextDivider({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSpacing1),
      child: Row(children: <Widget>[
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: kSpacing1, right: kSpacing2),
            child: const Divider(),
          ),
        ),
        Text(label),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: kSpacing2, right: kSpacing1),
            child: const Divider(),
          ),
        ),
      ]),
    );
  }
}
