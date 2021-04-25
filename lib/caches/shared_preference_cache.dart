import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceCache {
  final Future<SharedPreferences> _sharedPreference =
      SharedPreferences.getInstance();
  static const String is_dark_mode = 'is_dark_mode';
  static const String language_code = 'language_code';
  static const String currency_code = 'currency_code';

  SharedPreferenceCache._constructor();

  static final SharedPreferenceCache _instance =
      SharedPreferenceCache._constructor();

  static SharedPreferenceCache get instance => _instance;

  // === theme ===
  Future<bool> get darkMode {
    return _sharedPreference.then((prefs) {
      return prefs.getBool(is_dark_mode);
    });
  }

  Future<void> setDarkMode(bool value) {
    return _sharedPreference.then((prefs) {
      return prefs.setBool(is_dark_mode, value);
    });
  }

  // === currency ===
  Future<String> get currency {
    return _sharedPreference.then((prefs) {
      return prefs.getString(currency_code);
    });
  }

  Future<void> setCurrency(String value) {
    return _sharedPreference.then((prefs) {
      return prefs.setString(currency_code, value);
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
