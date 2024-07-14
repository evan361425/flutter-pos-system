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
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400.0),
          child: Column(
            children: [
              Expanded(child: wrapRow3(context)),
              row4,
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: Theme.of(context).colorScheme.surface,
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
      color: Theme.of(context).colorScheme.surface,
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
