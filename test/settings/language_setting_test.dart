import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/settings/language_setting.dart';

void main() {
  group('Language Setting', () {
    test('Parse language', () {
      final languageSetting = LanguageSetting();

      expect(languageSetting.parseLanguage(''), isNull);
      expect(languageSetting.parseLanguage('something'),
          equals(LanguageSetting.defaultLanguage));
      expect(languageSetting.parseLanguage('zh'),
          equals(LanguageSetting.defaultLanguage));
      expect(languageSetting.parseLanguage('zh_TW'),
          equals(LanguageSetting.defaultLanguage));
      expect(languageSetting.parseLanguage('zh_Hant'),
          equals(LanguageSetting.defaultLanguage));
      expect(languageSetting.parseLanguage('zh_Hant_TW'),
          equals(LanguageSetting.defaultLanguage));
    });
  });
}
