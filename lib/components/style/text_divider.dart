import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class TextDivider extends StatelessWidget {
  final String label;

  const TextDivider({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kHorizontalSpacing),
      child: Row(children: <Widget>[
        const Expanded(
          child: Divider(
            indent: kInternalSpacing,
            endIndent: kInternalSpacing,
          ),
        ),
        Text(label),
        const Expanded(
          child: Divider(
            indent: kInternalSpacing,
            endIndent: kInternalSpacing,
          ),
        ),
      ]),
    );
  }
}
