import 'package:flutter/material.dart';

class NumText extends StatelessWidget {
  final num data;

  final bool isBold;

  const NumText(this.data, {Key? key, this.isBold = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      data.toString(),
      textAlign: TextAlign.right,
      style: TextStyle(fontWeight: isBold ? FontWeight.bold : null),
    );
  }
}
