import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:possystem/caches/shared_preference_cache.dart';
import 'package:possystem/localizations.dart';

class LanguageProvider extends ChangeNotifier {
  // shared pref object
  static const supports = [
    Locale('zh', 'TW'),
    Locale('en', 'US'),
  ];

  // List of all supported locales
  static const delegates = [
    // A class which loads the translations from YAML files
    Local.delegate,
    // Built-in localization of basic text for Material widgets
    // (means those default Material widget such as alert dialog icon text)
    GlobalMaterialLocalizations.delegate,
    // Built-in localization for text direction LTR/RTL
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const Locale defaultLocale = Locale('zh', 'TW');

  // These delegates make sure that the localization data for the proper
  // language is loaded
  final SharedPreferenceCache _sharedPrefsCache = SharedPreferenceCache();

  // return a locale which will be used by the app
  Locale _locale;

  LanguageProvider() : _locale = defaultLocale;

  Locale initLocale() {
    _sharedPrefsCache.language.then((language) {
      if (language != null) {
        final codes = language.split('_');
        if (codes.length == 2) {
          _locale = Locale(codes[0], codes[1]);
        }
      }
    });

    return _locale;
  }

  Locale get locale => _locale;

  set locale(Locale locale) {
    _locale = locale;

    var code = '${locale.languageCode}_${locale.countryCode}';
    _sharedPrefsCache.setLanguage(code);

    notifyListeners();
  }

  static Locale localResolutionCallback(
    Locale locale,
    Iterable<Locale> supportedLocales,
  ) {
    // check if the current device locale is supported or not
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale?.languageCode ||
          supportedLocale.countryCode == locale?.countryCode) {
        return supportedLocale;
      }
    }

    // if the locale from the mobile device is not supported yet
    return defaultLocale;
  }
}
