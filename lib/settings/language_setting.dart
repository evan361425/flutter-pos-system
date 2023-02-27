import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:possystem/settings/setting.dart';

class LanguageSetting extends Setting<Locale> {
  // Make SettingsService a private variable so it is not used directly.
  static const defaultLanguage = Locale.fromSubtags(
    languageCode: 'zh',
    countryCode: 'TW',
  );

  static const supported = [
    defaultLanguage,
    Locale('en'),
  ];

  static const supportedNames = ['繁體中文', 'English'];

  @override
  final String key = 'language';

  @override
  bool get registryForApp => true;

  @override
  void initialize() {
    value = parseLanguage(service.get<String>(key)) ?? defaultLanguage;
  }

  @override
  Future<void> updateRemotely(Locale data) {
    return service.set<String>(key, data.toString());
  }

  Locale? parseLanguage(String? value) {
    if (value == null || value.isEmpty) return null;

    final codes = value.split('_');

    return supported.firstWhere(
      (e) => e.languageCode == codes[0],
      orElse: () => defaultLanguage,
    );
  }
}
