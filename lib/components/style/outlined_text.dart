import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;

  final String? badge;

  final double? textScaleFactor;

  const OutlinedText(
    this.text, {
    Key? key,
    this.badge,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.fromLTRB(12, 6.0, 12, 6.0),
      constraints: const BoxConstraints(minWidth: 64.0),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Text(text, textAlign: TextAlign.center),
    );

    if (badge == null) {
      return base;
    }

    return Stack(children: [
      base,
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          height: theme.badgeTheme.largeSize ?? 16.0,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: theme.badgeTheme.backgroundColor ?? theme.colorScheme.error,
            shape: const StadiumBorder(),
          ),
          padding: theme.badgeTheme.padding ??
              const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          child: Text(
            badge!,
            style: theme.textTheme.labelSmall!.copyWith(
              color: theme.colorScheme.onError,
            ),
            textAlign: TextAlign.center,
            textScaleFactor: textScaleFactor,
          ),
        ),
      )
    ]);
  }
}
