import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/settings/language_setting.dart';

void main() {
  group('Language Setting', () {
    test('Parse language', () {
      final languageSetting = LanguageSetting();

      expect(languageSetting.parseLanguage(''), isNull);
      expect(languageSetting.parseLanguage('zh'), equals(const Locale('zh')));
      expect(languageSetting.parseLanguage('zh_TW'),
          equals(const Locale('zh', 'TW')));
    });
  });
}
