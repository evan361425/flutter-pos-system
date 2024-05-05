import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/settings/language_setting.dart';

void main() {
  group('Language Setting', () {
    test('Parse language', () {
      final l = LanguageSetting.instance;
      expect(l.parseLanguage(''), isNull);
      expect(l.parseLanguage('something'), equals(LanguageSetting.defaultLanguage));
      expect(l.parseLanguage('zh'), equals(LanguageSetting.defaultLanguage));
      expect(l.parseLanguage('zh_TW'), equals(LanguageSetting.defaultLanguage));
      expect(l.parseLanguage('zh_Hant'), equals(LanguageSetting.defaultLanguage));
      expect(l.parseLanguage('zh_Hant_TW'), equals(LanguageSetting.defaultLanguage));
    });
  });
}
