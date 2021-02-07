import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceCache {
  final Future<SharedPreferences> _sharedPreference;
  static const String is_dark_mode = 'is_dark_mode';
  static const String language_code = 'language_code';

  SharedPreferenceCache() : _sharedPreference = SharedPreferences.getInstance();

  // === theme ===
  Future<bool> get isDarkMode {
    return _sharedPreference.then((prefs) {
      return prefs.getBool(is_dark_mode) ?? false;
    });
  }

  Future<void> setTheme(bool value) {
    return _sharedPreference.then((prefs) {
      return prefs.setBool(is_dark_mode, value);
    });
  }

  // === language ===
  Future<String> get language {
    return _sharedPreference.then((prefs) {
      return prefs.getString(language_code);
    });
  }

  Future<void> setLanguage(String value) {
    return _sharedPreference.then((prefs) {
      return prefs.setString(language_code, value);
    });
  }
}
