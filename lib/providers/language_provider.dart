import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';

class LanguageProvider extends ChangeNotifier {
  static late LanguageProvider instance;

  static const supports = [
    Locale('zh', 'TW'),
    Locale('en', 'US'),
  ];

  static const supportNames = [
    '繁體中文',
    'English',
  ];

  /// shared pref object
  static const delegates = <LocalizationsDelegate<dynamic>>[
    // A class which loads the translations from YAML files
    _LocalizationsDelegate(),
    // Built-in localization of basic text for Material widgets
    // (means those default Material widget such as alert dialog icon text)
    GlobalMaterialLocalizations.delegate,
    // Built-in localization for text direction LTR/RTL
    GlobalWidgetsLocalizations.delegate,
  ];

  /// List of all supported locales
  static const Locale defaultLocale = Locale('en', 'US');

  Locale? _locale;

  LanguageProvider() {
    instance = this;
  }

  bool get isReady => _locale != null;

  Locale get locale => _locale!;

  void initialize() {
    final locale = Cache.instance.get<String>(Caches.language_code);
    final parsed = _parseLanguage(locale);

    _locale = parsed ?? LanguageProvider.defaultLocale;
  }

  Locale localeListResolutionCallback(
    List<Locale>? locales,
    Iterable<Locale> supports,
  ) {
    if (locales == null) return defaultLocale;
    if (_locale != null) return _locale!;

    Locale? _parse(bool Function(Locale) test) {
      try {
        final supported = supports.firstWhere(test);
        _locale = supported;

        return supported;
      } catch (e) {
        return null;
      }
    }

    // check if the current device locale is supported or not
    for (final locale in locales) {
      final allowed = _parse((e) => e == locale) ??
          _parse((e) => e.languageCode == locale.languageCode) ??
          _parse((e) => e.countryCode == locale.countryCode);

      if (allowed != null) {
        return allowed;
      }
    }

    return defaultLocale;
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

  void translatorFilesChanged() {
    notifyListeners();
  }
}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations object
class _LocalizationsDelegate extends LocalizationsDelegate<Translator> {
  const _LocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<Translator> load(Locale locale) async {
    await Translator.instance.load(locale);
    LanguageProvider.instance.translatorFilesChanged();
    return Translator.instance;
  }

  // already set in [LanguageProvider.localResolutionCallback]
  @override
  bool shouldReload(_LocalizationsDelegate old) => false;
}
