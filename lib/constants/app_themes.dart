import 'package:flutter/material.dart';

/// Want to build your own theme?
/// https://github.com/rxlabz/panache
class AppThemes {
  static final ThemeData lightTheme = ThemeData()
    ..setGradientColors(const [
      Colors.indigo,
      Colors.blue,
      Colors.green,
    ]);

  static final ThemeData darkTheme = ThemeData.dark()
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
