import 'package:possystem/translator.dart';

class Validator {
  static String? Function(String?) positiveNumber(
    String fieldName, {
    num? maximum,
  }) {
    return (String? value) {
      final number = num.tryParse(value ?? '');

      if (number == null) {
        return tt('validator.number.type', {'field': fieldName});
      } else if (number < 0) {
        return tt('validator.number.positive', {'field': fieldName});
      } else if (maximum != null && maximum < number) {
        return tt('validator.number.maximum',
            {'field': fieldName, 'maximum': maximum});
      }

      return null;
    };
  }

  static String? Function(String?) positiveInt(
    String fieldName, {
    num? maximum,
  }) {
    return (String? value) {
      final number = int.tryParse(value ?? '');
      if (number == null) {
        return tt('validator.integer.type', {'field': fieldName});
      } else if (number < 0) {
        return tt('validator.number.positive', {'field': fieldName});
      } else if (maximum != null && maximum < number) {
        return tt(
          'validator.number.maximum',
          {'field': fieldName, 'maximum': maximum},
        );
      } else {
        return null;
      }
    };
  }

  static String? Function(String?) isNumber(String fieldName) {
    return (String? value) {
      final number = num.tryParse(value ?? '');

      if (number == null) {
        return tt('validator.number.type', {'field': fieldName});
      } else {
        return null;
      }
    };
  }

  static String? Function(String?) textLimit(String fieldName, int limit) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return tt('validator.string.type', {'field': fieldName});
      } else if (value.length > limit) {
        return tt(
          'validator.string.maximum',
          {'field': fieldName, 'maximum': limit},
        );
      }

      return null;
    };
  }
}
