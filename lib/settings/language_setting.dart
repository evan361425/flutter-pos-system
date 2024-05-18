import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:possystem/settings/setting.dart';

class LanguageSetting extends Setting<Language> {
  static final instance = LanguageSetting._();

  static const defaultValue = Language.en;

  LanguageSetting._() {
    value = defaultValue;
  }

  @override
  final String key = 'language';

  @override
  bool get registryForApp => true;

  @override
  void initialize() {
    value = parseLanguage(service.get<String>(key)) ?? defaultValue;
    notifyListeners();
  }

  @override
  Future<void> updateRemotely(Language data) {
    return service.set<String>(key, data.locale.toString());
  }

  Language? parseLanguage(String? value) {
    if (value == null || value.isEmpty) return null;

    final codes = value.split('_');

    return Language.values.firstWhere(
      (e) => e.locale.languageCode == codes[0],
      orElse: () => defaultValue,
    );
  }
}

enum Language {
  zhTW(Locale('zh', 'TW'), '繁體中文'),
  en(Locale('en'), 'English');

  final Locale locale;

  final String title;

  const Language(this.locale, this.title);
}
