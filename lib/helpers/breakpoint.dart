import 'package:flutter/widgets.dart';

/// follow material design breakpoints
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum Breakpoint {
  /// Below 600
  ///
  /// - Phone in portrait
  compact(0, 600),

  /// Between 600 and 840
  ///
  /// - Tablet in portrait
  /// - Foldable in portrait (unfolded)
  medium(600, 840),

  /// Between 840 and 1200
  ///
  /// - Phone in landscape
  /// - Tablet in landscape
  /// - Foldable in landscape (unfolded)
  /// - Desktop
  expanded(840, 1200),

  /// Between 1200 and 1600
  ///
  /// - Desktop
  large(1200, 1600),

  /// Above 1600
  ///
  /// - Desktop
  /// - Ultra-wide
  extraLarge(1600, double.maxFinite);

  final double min;
  final double max;

  const Breakpoint(this.min, this.max);

  static Breakpoint find({BoxConstraints? box, double? width}) {
    assert(box != null || width != null, 'box or width must be provided');
    width ??= box!.maxWidth;

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

  /// Lookup the value based on the breakpoint
  T lookup<T>({
    T? extraLarge,
    T? large,
    T? expanded,
    T? medium,
    required T compact,
  }) {
    switch (this) {
      case Breakpoint.extraLarge:
        if (extraLarge != null) {
          return extraLarge;
        }
      case Breakpoint.large:
        if (large != null) {
          return large;
        }
      case Breakpoint.expanded:
        if (expanded != null) {
          return expanded;
        }
      case Breakpoint.medium:
        if (medium != null) {
          return medium;
        }
      default:
    }
    return compact;
  }

  bool operator <=(Breakpoint other) {
    return max <= other.max;
  }
}
