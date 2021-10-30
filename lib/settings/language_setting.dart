import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:possystem/settings/setting.dart';

class LanguageSetting extends Setting<Locale> {
  // Make SettingsService a private variable so it is not used directly.
  static const defaultLanguage = Locale('zh', 'TW');

  /// shared pref object
  static const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const supports = [
    defaultLanguage,
    Locale('en'),
  ];

  static const supportNames = [
    '繁體中文',
    'English',
  ];

  @override
  final String key = 'language';

  @override
  bool get registyForApp => true;

  @override
  void initialize() {
    value = _parseLanguage(service.get<String>(key)) ?? defaultLanguage;
  }

  @override
  Future<void> updateRemotely(Locale data) {
    return service.set<String>(key, data.toString());
  }

  Locale? _parseLanguage(String? value) {
    if (value == null || value.isEmpty) return null;

    final codes = value.split('_');

    return Locale(codes[0], codes.length == 1 ? null : codes[1]);
  }
}
