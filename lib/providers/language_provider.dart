import 'package:flutter/material.dart';
import 'package:possystem/caches/sharedpref/shared_preference_helper.dart';

class LanguageProvider extends ChangeNotifier {
  // shared pref object
  SharedPreferenceHelper _sharedPrefsHelper;

  static const supports = [
    Locale('zh', 'TW'),
    Locale('en', 'US'),
  ];

  Locale _appLocale = Locale('zh', 'TW');

  LanguageProvider() {
    _sharedPrefsHelper = SharedPreferenceHelper();
  }

  Locale _parseLocale(String value) {
    List<String> values = value.split('-');
    return values.length == 2 ?
      Locale(values[0], values[1]) :
      Locale('zh', 'TW');
  }

  Locale get appLocale {
    _sharedPrefsHelper.appLocale.then((localeValue) {
      if (localeValue != null) {
        _appLocale = _parseLocale(localeValue);
      }
    });

    return _appLocale;
  }

  void updateLanguage(String localeValue) {
    _appLocale = _parseLocale(localeValue);

    _sharedPrefsHelper.changeLanguage(localeValue);
    notifyListeners();
  }
}
