import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;

  final String? badge;

  final EdgeInsets? margin;

  /// * `textStyle` - Theme.textTheme.labelLarge
  /// * `backgroundColor` - transparent
  /// * `foregroundColor`
  ///   * disabled - Theme.colorScheme.onSurface(0.38)
  ///   * others - Theme.colorScheme.primary
  /// * `overlayColor`
  ///   * hovered - Theme.colorScheme.primary(0.08)
  ///   * focused or pressed - Theme.colorScheme.primary(0.12)
  ///   * others - null
  /// * `shadowColor` - null
  /// * `surfaceTintColor` - null
  /// * `elevation` - 0
  /// * `padding`
  ///   * `textScaleFactor <= 1` - horizontal(16)
  ///   * `1 < textScaleFactor <= 2` - lerp(horizontal(16), horizontal(8))
  ///   * `2 < textScaleFactor <= 3` - lerp(horizontal(8), horizontal(4))
  ///   * `3 < textScaleFactor` - horizontal(4)
  /// * `minimumSize` - Size(64, 40)
  /// * `fixedSize` - null
  /// * `maximumSize` - Size.infinite
  /// * `side`
  ///   * disabled - BorderSide(color: Theme.colorScheme.onSurface(0.12))
  ///   * others - BorderSide(color: Theme.colorScheme.outline)
  /// * `shape` - StadiumBorder()
  /// * `mouseCursor`
  ///   * disabled - SystemMouseCursors.basic
  ///   * others - SystemMouseCursors.click
  /// * `visualDensity` - theme.visualDensity
  /// * `tapTargetSize` - theme.materialTapTargetSize
  /// * `animationDuration` - kThemeChangeDuration
  /// * `enableFeedback` - true
  /// * `alignment` - Alignment.center
  /// * `splashFactory` - Theme.splashFactory
  const OutlinedText(
    this.text, {
    super.key,
    this.badge,
    this.margin,
  });

  @override

  /// Mainly copy from [ButtonStyleButton]
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ButtonStyleButton.scaledPadding(
      const EdgeInsets.symmetric(horizontal: 16),
      const EdgeInsets.symmetric(horizontal: 8),
      const EdgeInsets.symmetric(horizontal: 4),
      MediaQuery.textScalerOf(context).scale(1),
    );

    final base = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 64, minHeight: 40),
      child: Material(
        textStyle: theme.textTheme.labelLarge!.copyWith(color: theme.colorScheme.primary),
        shape: StadiumBorder(
          side: BorderSide(color: theme.colorScheme.outline),
        ),
        color: Colors.transparent,
        type: MaterialType.button,
        child: Padding(
          padding: padding,
          child: Align(
            alignment: Alignment.center,
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: Text(text),
          ),
        ),
      ),
    );

    if (badge == null) {
      return Padding(padding: margin ?? EdgeInsets.zero, child: base);
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Badge(
        // too high will causing overlapping on top of scrollable view
        alignment: const AlignmentDirectional(1.0, -0.6),
        label: Text(badge!),
        child: base,
      ),
    );
  }
}
