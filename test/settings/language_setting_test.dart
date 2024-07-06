import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/settings/language_setting.dart';

void main() {
  group('Language Setting', () {
    test('Parse language', () {
      final l = LanguageSetting.instance;
      expect(l.parseLanguage(''), isNull);
      expect(l.parseLanguage('something'), equals(null));
      expect(l.parseLanguage('zh'), equals(Language.zhTW));
      expect(l.parseLanguage('zh_TW'), equals(Language.zhTW));
      expect(l.parseLanguage('zh_Hant'), equals(Language.zhTW));
      expect(l.parseLanguage('zh_Hant_TW'), equals(Language.zhTW));
    });
  });
}
