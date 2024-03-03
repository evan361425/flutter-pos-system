import 'package:flutter/material.dart';

class CardInfoText extends StatelessWidget {
  final Widget child;

  const CardInfoText({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 100),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
