import 'package:flutter/material.dart';
import 'package:possystem/caches/shared_preference_cache.dart';

class ThemeProvider extends ChangeNotifier {
  bool _darkMode = false;

  bool get darkMode {
    SharedPreferenceCache.instance.darkMode.then(setDarkMode);
    return _darkMode;
  }

  set darkMode(bool value) {
    setDarkMode(value);
    SharedPreferenceCache.instance.setDarkMode(value);
  }

  void setDarkMode(bool value) {
    if (value != null && _darkMode != value) {
      _darkMode = value;
      notifyListeners();
    }
  }
}
