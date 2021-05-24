import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:possystem/services/cache.dart';

class ThemeProvider extends ChangeNotifier {
  bool _darkMode;

  bool get darkMode => _darkMode;

  Future<bool> getDarkMode() async {
    // get from cache, is not found get system setting
    _darkMode ??=
        (await Cache.instance.get<bool>(Caches.dark_mode)) ?? defaultTheme;

    return _darkMode;
  }

  Future<void> setDarkMode(bool value) async {
    await Cache.instance.set(Caches.dark_mode, value);
    if (_darkMode != value) {
      _darkMode = value;
      notifyListeners();
    }
  }

  static bool get defaultTheme =>
      SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
}
