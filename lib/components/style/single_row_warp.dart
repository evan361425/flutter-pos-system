import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class SingleRowWrap extends StatelessWidget {
  final List<Widget> children;

  final Color? color;

  const SingleRowWrap({
    super.key,
    required this.children,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.0,
      color: color,
      shadowColor: color,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kHorizontalSpacing),
          child: Wrap(
            spacing: kInternalSpacing,
            children: children,
          ),
        ),
      ),
    );
  }
}
