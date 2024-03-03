import 'package:flutter/material.dart';

class OrientatedView extends StatelessWidget {
  final Widget row1;

  final Widget row2;

  final Widget row3_1;
  final Widget row3_2;
  final Widget row3_3;

  final Widget row4;

  const OrientatedView({
    super.key,
    required this.row1,
    required this.row2,
    required this.row3_1,
    required this.row3_2,
    required this.row3_3,
    required this.row4,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return orientation == Orientation.portrait
            ? _portrait(context)
            : _landscape(context);
      },
    );
  }

  Widget _portrait(BuildContext context) {
    return Column(
      key: const Key('order.orientation.portrait'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: Theme.of(context).colorScheme.background,
          child: row1,
        ),
        Expanded(child: row2),
        Expanded(flex: 3, child: wrapRow3(context)),
        row4,
      ],
    );
  }

  Widget _landscape(BuildContext context) {
    return Row(
      key: const Key('order.orientation.landscape'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300.0),
            child: Column(
              children: [
                Expanded(child: wrapRow3(context)),
                row4,
              ],
            ),
          ),
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: Theme.of(context).colorScheme.background,
                child: row1,
              ),
              Expanded(child: row2),
            ],
          ),
        ),
      ],
    );
  }

  Widget wrapRow3(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      color: Theme.of(context).colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row3_1,
          row3_2,
          row3_3,
        ],
      ),
    );
  }
}
