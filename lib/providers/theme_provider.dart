import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:possystem/services/cache.dart';

class ThemeProvider extends ChangeNotifier {
  late bool _darkMode;

  bool get darkMode => _darkMode;

  void initialize() {
    // get from cache, if not found get system setting
    final value = Cache.instance.get<bool>(Caches.dark_mode);
    _darkMode = value ?? defaultTheme;
  }

  Future<void> setDarkMode(bool value) async {
    await Cache.instance.set(Caches.dark_mode, value);
    if (_darkMode != value) {
      _darkMode = value;
      notifyListeners();
    }
  }

  static bool get defaultTheme =>
      SchedulerBinding.instance?.window.platformBrightness == Brightness.dark;
}
