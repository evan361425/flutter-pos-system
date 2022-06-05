import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:possystem/settings/setting.dart';

class LanguageSetting extends Setting<Locale> {
  // Make SettingsService a private variable so it is not used directly.
  static const defaultLanguage = Locale('zh', 'TW');

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

    return Locale(codes[0], codes.length == 1 ? null : codes[1]);
  }
}
