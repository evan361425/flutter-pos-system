import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/services/cache.dart';

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

  Locale _locale;

  LanguageProvider();

  Locale get locale => _locale;

  Future<Locale> getLocale() async {
    _locale ??= _parseLanguage(
          await Cache.instance.get<String>(Caches.language_code),
        ) ??
        LanguageProvider.defaultLocale;
    return _locale;
  }

  Future<void> setLocale(Locale locale) async {
    final code = '${locale.languageCode}_${locale.countryCode}';
    await Cache.instance.set<String>(Caches.language_code, code);

    if (locale != _locale) {
      print('language select $locale');
      _locale = locale;
      notifyListeners();
    }
  }

  Locale _parseLanguage(String value) {
    final codes = value.split('_');
    if (codes.isEmpty) return null;

    return Locale(codes[0], codes.length == 1 ? null : codes[1]);
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
