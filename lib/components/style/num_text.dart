import 'package:flutter/material.dart';

class NumText extends StatelessWidget {
  final num data;

  const NumText(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(data.toString(), textAlign: TextAlign.right);
  }
}
