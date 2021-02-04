import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:possystem/app_localizations.dart';
import 'package:possystem/caches/sharedpref/shared_preference_helper.dart';

class LanguageProvider extends ChangeNotifier {
  // shared pref object
  SharedPreferenceHelper _sharedPrefsHelper;

  //List of all supported locales
  static const supports = [
    Locale('zh', 'TW'),
    Locale('en', 'US'),
  ];

  //These delegates make sure that the localization data for the proper
  // language is loaded
  static const delegates = [
    //A class which loads the translations from YAML files
    Trans.delegate,
    //Built-in localization of basic text for Material widgets
    // (means those default Material widget such as alert dialog icon text)
    GlobalMaterialLocalizations.delegate,
    //Built-in localization for text direction LTR/RTL
    GlobalWidgetsLocalizations.delegate,
  ];

  //return a locale which will be used by the app
  static Locale localResolutionCallback(
      Locale locale, Iterable<Locale> supportedLocales) {
    //check if the current device locale is supported or not
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale?.languageCode ||
          supportedLocale.countryCode == locale?.countryCode) {
        return supportedLocale;
      }
    }
    //if the locale from the mobile device is not supported yet,
    //user the first one from the list (in our case, that will be English)
    return supportedLocales.first;
  }

  Locale _appLocale = Locale('zh', 'TW');

  LanguageProvider() {
    _sharedPrefsHelper = SharedPreferenceHelper();
  }

  Locale _parseLocale(String value) {
    var values = value.split('_');
    return values.length == 2
        ? Locale(values[0], values[1])
        : Locale('zh', 'TW');
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
