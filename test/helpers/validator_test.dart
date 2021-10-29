import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/validator.dart';

void main() {
  group('Validator', () {
    test('#positiveNumber', () {
      final validator = Validator.positiveNumber('test');

      expect(validator(null), isNotNull);
      expect(validator('abc'), isNotNull);
      expect(validator('-1.1'), isNotNull);
      expect(validator('1.2'), isNull);

      final maximum = Validator.positiveNumber('test', maximum: 5);
      expect(maximum('6.1'), isNotNull);
      expect(maximum('5'), isNull);
    });

    test('#positiveInt', () {
      final validator = Validator.positiveInt('test');

      expect(validator(null), isNotNull);
      expect(validator('abc'), isNotNull);
      expect(validator('-1'), isNotNull);
      expect(validator('-1.1'), isNotNull);
      expect(validator('1.2'), isNotNull);
      expect(validator('1'), isNull);

      final maximum = Validator.positiveInt('test', maximum: 5, minimum: 3);
      expect(maximum('6.1'), isNotNull);
      expect(maximum('6'), isNotNull);
      expect(maximum('2'), isNotNull);
      expect(maximum('5'), isNull);
    });

    test('#isNumber', () {
      final validator = Validator.isNumber('test');

      expect(validator(null), isNotNull);
      expect(validator('abc'), isNotNull);
      expect(validator('-1.1'), isNull);
      expect(validator('1.2'), isNull);
    });

    test('#textLimit', () {
      final validator = Validator.textLimit('test', 2);

      expect(validator(null), isNotNull);
      expect(validator(''), isNotNull);
      expect(validator('abc'), isNotNull);
      expect(validator('1.2'), isNotNull);
      expect(validator('長度三'), isNotNull);
      expect(validator('😂😂'), isNotNull);
      expect(validator('ab'), isNull);
      expect(validator('二長'), isNull);
      expect(validator('😂'), isNull);
    });
  });
}
