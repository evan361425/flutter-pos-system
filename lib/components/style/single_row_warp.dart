import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';

class SingleRowWrap extends StatelessWidget {
  final List<Widget> children;

  const SingleRowWrap({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacing1),
          child: Wrap(
            spacing: kSpacing1,
            children: children,
          ),
        ),
      ),
    );
  }
}
