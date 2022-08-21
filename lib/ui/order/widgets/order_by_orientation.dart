import 'package:flutter/material.dart';

class OrderByOrientation extends StatelessWidget {
  final Widget row1;

  final Widget row2;

  final Widget row3;

  final Widget row4;

  const OrderByOrientation({
    Key? key,
    required this.row1,
    required this.row2,
    required this.row3,
    required this.row4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return orientation == Orientation.portrait ? _portrait() : _landscape();
      },
    );
  }

  Widget _portrait() {
    return Column(
      key: const Key('order.orientation.portrait'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row1,
        Expanded(child: row2),
        Expanded(flex: 3, child: row3),
        row4,
      ],
    );
  }

  Widget _landscape() {
    return Row(
      key: const Key('order.orientation.landscape'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300.0),
            child: Column(
              children: [
                Expanded(child: row3),
                row4,
              ],
            ),
          ),
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              row1,
              Expanded(child: row2),
            ],
          ),
        ),
      ],
    );
  }
}
