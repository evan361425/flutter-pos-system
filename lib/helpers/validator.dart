import 'package:possystem/translator.dart';

class Validator {
  static String? Function(Object?) positiveNumber(
    String fieldName, {
    num? maximum,
    bool allowNull = false,
  }) {
    return (Object? value) {
      final number = num.tryParse('$value');

      if (number == null) {
        if (!allowNull) {
          return S.invalidNumberType(fieldName);
        }
      } else if (number < 0) {
        return S.invalidPositiveNumber(fieldName);
      } else if (maximum != null && maximum < number) {
        return S.invalidNumberMaximum(fieldName, maximum);
      }

      return null;
    };
  }

  static String? Function(String?) positiveInt(
    String fieldName, {
    int? maximum,
    int? minimum,
    bool allowNull = false,
  }) {
    return (String? value) {
      final number = int.tryParse(value ?? '');
      if (number == null) {
        if (!allowNull) {
          return S.invalidIntegerType(fieldName);
        }
      } else if (number < 0) {
        return S.invalidPositiveNumber(fieldName);
      } else if (maximum != null && maximum < number) {
        return S.invalidNumberMaximum(fieldName, maximum);
      } else if (minimum != null && minimum > number) {
        return S.invalidNumberMinimum(fieldName, minimum);
      } else {
        return null;
      }
    };
  }

  static String? Function(String?) isNumber(
    String fieldName, {
    bool allowNull = false,
  }) {
    return (String? value) {
      final number = num.tryParse(value ?? '');

      if (number == null) {
        if (!allowNull) {
          return S.invalidNumberType(fieldName);
        }
      }
      return null;
    };
  }

  static String? Function(String?) textLimit(String fieldName, int limit) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return S.invalidEmptyString(fieldName);
      } else if (value.length > limit) {
        return S.invalidStringMaximum(fieldName, limit);
      }

      return null;
    };
  }
}
