import 'package:flutter/material.dart';

/// Want to build your own theme?
/// https://github.com/rxlabz/panache
class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF448AFF),
  )..setGradientColors(const [
      // Plum Plate
      Color(0xFFB0CDFF),
      Color(0xFFD8E5FB),
      Color(0xFFC3F9FE),
    ]);

  static final ThemeData darkTheme = ThemeData.dark(useMaterial3: true)
    ..setGradientColors(const [
      Color(0xFF1F1B24),
      Color(0xFF2e2356),
    ]);
}

extension GradientColorsTheme on ThemeData {
  static final Map<Brightness, List<Color>> _gradientColors = {};

  void setGradientColors(List<Color> colors) {
    _gradientColors[brightness] = colors;
  }

  List<Color> get gradientColors {
    return _gradientColors[brightness]!;
  }
}
