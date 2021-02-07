import 'package:flutter/material.dart';
import 'package:possystem/caches/shared_preference_cache.dart';

class ThemeProvider extends ChangeNotifier {
  // shared pref object
  final SharedPreferenceCache _sharedPrefsCache = SharedPreferenceCache();

  bool _isDarkModeOn = false;

  bool get isDarkModeOn {
    _sharedPrefsCache.isDarkMode.then((statusValue) {
      _isDarkModeOn = statusValue;
    });

    return _isDarkModeOn;
  }

  ThemeMode get mode {
    return isDarkModeOn ? ThemeMode.dark : ThemeMode.light;
  }

  void updateTheme(bool isDarkModeOn) {
    _sharedPrefsCache.setTheme(isDarkModeOn);
    _sharedPrefsCache.isDarkMode.then((darkModeStatus) {
      _isDarkModeOn = darkModeStatus;
    });

    notifyListeners();
  }
}
