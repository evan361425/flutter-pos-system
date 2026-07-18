import 'package:flutter/widgets.dart';
import 'package:possystem/translator.dart';

class Validator {
  static String? Function(Object?) positiveNumber(
    String fieldName, {
    num? maximum,
    bool allowNull = false,
    FocusNode? focusNode,
  }) {
    return (Object? value) {
      final number = num.tryParse('$value');
      String? error;

      if (number == null) {
        if (!allowNull) {
          error = S.invalidNumberType(fieldName);
        }
      } else if (number < 0) {
        error = S.invalidNumberPositive(fieldName);
      } else if (maximum != null && maximum < number) {
        error = S.invalidNumberMaximum(fieldName, maximum);
      }

      if (error != null) {
        focusNode?.requestFocus();
      }

      return error;
    };
  }

  static String? Function(String?) positiveInt(
    String fieldName, {
    int? maximum,
    int? minimum,
    bool allowNull = false,
    FocusNode? focusNode,
  }) {
    return (String? value) {
      final number = int.tryParse(value ?? '');
      String? error;

      if (number == null) {
        if (!allowNull) {
          error = S.invalidIntegerType(fieldName);
        }
      } else if (number < 0) {
        error = S.invalidNumberPositive(fieldName);
      } else if (maximum != null && maximum < number) {
        error = S.invalidNumberMaximum(fieldName, maximum);
      } else if (minimum != null && minimum > number) {
        error = S.invalidNumberMinimum(fieldName, minimum);
      }

      if (error != null) {
        focusNode?.requestFocus();
      }

      return error;
    };
  }

  static String? Function(String?) isNumber(
    String fieldName, {
    bool allowNull = false,
    FocusNode? focusNode,
  }) {
    return (String? value) {
      final number = num.tryParse(value ?? '');
      String? error;

      if (number == null) {
        if (!allowNull) {
          error = S.invalidNumberType(fieldName);
        }
      }

      if (error != null) {
        focusNode?.requestFocus();
      }

      return error;
    };
  }

  static String? Function(String?) textLimit(
    String fieldName,
    int limit, {
    FocusNode? focusNode,
    String? Function(String)? validator,
  }) {
    return (String? value) {
      String? error;

      if (value == null || value.isEmpty) {
        error = S.invalidStringEmpty(fieldName);
      } else if (value.characters.length > limit) {
        error = S.invalidStringMaximum(fieldName, limit);
      } else if (validator != null) {
        error = validator(value);
      }

      if (error != null) {
        focusNode?.requestFocus();
      }

      return error;
    };
  }
}
