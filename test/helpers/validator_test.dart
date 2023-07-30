import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/validator.dart';

import '../test_helpers/translator.dart';

void main() {
  group('Validator', () {
    test('#positiveNumber', () {
      final fn = MyFocusNode();
      final validator = Validator.positiveNumber('test', focusNode: fn);

      expect(validator(null), isNotNull);
      expect(validator('abc'), isNotNull);
      expect(validator('-1.1'), isNotNull);
      expect(validator('1.2'), isNull);
      expect(fn.focusCounter, equals(3));

      final maximum = Validator.positiveNumber('test', maximum: 5);
      expect(maximum('6.1'), isNotNull);
      expect(maximum('5'), isNull);
    });

    test('#positiveInt', () {
      final fn = MyFocusNode();
      final validator = Validator.positiveInt('test', focusNode: fn);

      expect(validator(null), isNotNull);
      expect(validator('abc'), isNotNull);
      expect(validator('-1'), isNotNull);
      expect(validator('-1.1'), isNotNull);
      expect(validator('1.2'), isNotNull);
      expect(validator('1'), isNull);
      expect(fn.focusCounter, equals(5));

      final maximum = Validator.positiveInt('test', maximum: 5, minimum: 3);
      expect(maximum('6.1'), isNotNull);
      expect(maximum('6'), isNotNull);
      expect(maximum('2'), isNotNull);
      expect(maximum('5'), isNull);
    });

    test('#isNumber', () {
      final fn = MyFocusNode();
      final validator = Validator.isNumber('test', focusNode: fn);

      expect(validator(null), isNotNull);
      expect(validator('abc'), isNotNull);
      expect(validator('-1.1'), isNull);
      expect(validator('1.2'), isNull);
      expect(fn.focusCounter, equals(2));
    });

    test('#textLimit', () {
      final validator = Validator.textLimit('test', 2);

      expect(validator(null), isNotNull);
      expect(validator(''), isNotNull);
      expect(validator('abc'), isNotNull);
      expect(validator('1.2'), isNotNull);
      expect(validator('長度三'), isNotNull);
      expect(validator('😂😂😂'), isNotNull);
      expect(validator('ab'), isNull);
      expect(validator('二長'), isNull);
      expect(validator('😂😂'), isNull);
    });

    setUpAll(() {
      initializeTranslator();
    });
  });
}

class MyFocusNode extends FocusNode {
  int focusCounter = 0;

  @override
  void requestFocus([FocusNode? node]) {
    focusCounter++;
  }
}
