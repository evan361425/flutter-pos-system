import 'package:flutter/widgets.dart';

/// follow material design breakpoints
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum Breakpoint {
  /// - Phone in portrait
  compact(0, 600),

  /// - Tablet in portrait
  /// - Foldable in portrait (unfolded)
  medium(600, 840),

  /// - Phone in landscape
  /// - Tablet in landscape
  /// - Foldable in landscape (unfolded)
  /// - Desktop
  expanded(840, 1200),

  /// - Desktop
  large(1200, 1600),

  /// - Desktop
  /// - Ultra-wide
  extraLarge(1600, 0x7FFFFFFFFFFFFFFF);

  final int min;
  final int max;

  const Breakpoint(this.min, this.max);

  static Breakpoint find({BoxConstraints? box, double? width}) {
    width ??= box?.maxWidth ?? 0;

    if (width < compact.max) {
      return compact;
    }
    if (width < medium.max) {
      return medium;
    }
    if (width < expanded.max) {
      return expanded;
    }
    if (width < large.max) {
      return large;
    }
    return extraLarge;
  }

  bool operator <=(Breakpoint other) {
    return max <= other.max;
  }
}
