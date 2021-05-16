import 'package:flutter/material.dart';
import 'package:possystem/services/cache.dart';

class ThemeProvider extends ChangeNotifier {
  bool _darkMode;

  bool get darkMode => _darkMode;

  Future<bool> getDarkMode() async {
    _darkMode ??= await Cache.instance.get<bool>(Caches.dark_mode);
    return _darkMode;
  }

  Future<void> setDarkMode(bool value) async {
    await Cache.instance.set(Caches.dark_mode, value);
    if (_darkMode != value) {
      _darkMode = value;
      notifyListeners();
    }
  }
}
