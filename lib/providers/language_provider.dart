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

  Locale _locale = defaultLocale;

  LanguageProvider();

  Locale get locale {
    SharedPreferenceCache.instance.language.then(_setLanguage);
    return _locale;
  }

  set locale(Locale locale) {
    final code = '${locale.languageCode}_${locale.countryCode}';

    SharedPreferenceCache.instance.setLanguage(code);
    _setLanguage(code);
  }

  void _setLanguage(String value) {
    if (value == null) return;

    final codes = value.split('_');
    if (codes.isEmpty) return;

    if (codes[0] == _locale.languageCode && codes.length == 1 ||
        codes[1] == _locale.countryCode) return;

    _locale = Locale(codes[0], codes.length == 1 ? null : codes[1]);
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
