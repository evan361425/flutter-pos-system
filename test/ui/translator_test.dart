import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/translator.dart';

void main() {
  group('#translate', () {
    test('should use key if not found', () {
      expect(tt('some-key'), equals('some-key'));
    });

    test('should replace bracket with name by map value', () {
      Translator.instance.data = {'key': 'string with {variable}.'};
      expect(tt('key', {'variable': 'qq'}), equals('string with qq.'));
    });
  });
}
