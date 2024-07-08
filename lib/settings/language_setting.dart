import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:possystem/settings/setting.dart';

/// Language setting allow given null language which means system default.
class LanguageSetting extends Setting<Language?> {
  Language? _systemLanguage;

  static final instance = LanguageSetting._();

  LanguageSetting._() {
    value = null;
  }

  @override
  final String key = 'language';

  @override
  bool get registryForApp => true;

  /// Set system language for fallback.
  ///
  /// This is not idempotent, it will only set once.
  set systemLanguage(String locale) {
    _systemLanguage ??= parseLanguage(locale)!;
  }

  Language get language => value ?? _systemLanguage ?? Language.en;

  @override
  void initialize() {
    value = parseLanguage(service.get<String>(key));
    notifyListeners();
  }

  @override
  Future<void> updateRemotely(Language? data) {
    return service.set<String>(key, data?.locale.toString() ?? '');
  }

  Language? parseLanguage(String? value) {
    if (value == null || value.isEmpty) return null;

    final codes = value.split('_');

    return Language.values.firstWhereOrNull((e) => e.locale.languageCode == codes[0]);
  }
}

enum Language {
  zhTW(Locale('zh', 'TW'), '繁體中文'),
  en(Locale('en'), 'English');

  final Locale locale;

  final String title;

  const Language(this.locale, this.title);
}
