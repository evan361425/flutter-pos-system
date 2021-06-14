import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:possystem/helpers/logger.dart';
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

  late Locale _locale;

  /// check if user set their prefer locale
  bool _isCustom = false;

  Locale get locale => _locale;

  void initialize() {
    final locale = Cache.instance.get<String>(Caches.language_code);
    final parsed = _parseLanguage(locale);

    _isCustom = parsed != null;
    _locale = parsed ?? LanguageProvider.defaultLocale;
  }

  Locale localResolutionCallback(
    Locale? locale,
    Iterable<Locale> supports,
  ) {
    if (locale == null) return defaultLocale;

    Locale? _parse(bool Function(Locale) test) {
      try {
        final supported = supports.firstWhere(test);
        if (!_isCustom) _locale = supported;

        return supported;
      } catch (e) {
        return null;
      }
    }

    // check if the current device locale is supported or not
    return _parse((e) => e == locale) ??
        _parse((e) => e.languageCode == locale.languageCode) ??
        _parse((e) => e.countryCode == locale.countryCode) ??
        defaultLocale;
  }

  Future<void> setLocale(Locale locale) async {
    var code = locale.toString();
    info(code, 'setting.language');
    await Cache.instance.set<String>(Caches.language_code, code);

    if (locale != _locale) {
      _locale = locale;
      notifyListeners();
    }
  }

  Locale? _parseLanguage(String? value) {
    if (value == null || value.isEmpty) return null;

    final codes = value.split('_');

    return Locale(codes[0], codes.length == 1 ? null : codes[1]);
  }
}
