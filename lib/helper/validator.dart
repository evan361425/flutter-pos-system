import 'package:possystem/localizations.dart';

class Validator {
  static Local? tranlator;

  static String? Function(String?) positiveNumber(
    String fieldName, {
    num? maximum,
  }) {
    return (String? value) {
      final number = num.tryParse(value ?? '');

      if (number == null) {
        return '$fieldName 必須是數字';
      } else if (number < 0) {
        return '$fieldName 不能為負數';
      } else if (maximum != null && maximum < number) {
        return '$fieldName 不能大於 $maximum';
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
        return '$fieldName 必須是整數';
      } else if (number < 0) {
        return '$fieldName 不能為負數';
      } else if (maximum != null && maximum < number) {
        return '$fieldName 不能大於 $maximum';
      } else {
        return null;
      }
    };
  }

  static String? Function(String?) isNumber(String fieldName) {
    return (String? value) {
      if (num.tryParse(value!) == null) {
        return '$fieldName 必須是數字';
      } else {
        return null;
      }
    };
  }

  static String? Function(String?) textLimit(String fieldName, int limit) {
    return (String? value) {
      if (value!.isEmpty) {
        return '$fieldName 不能為空';
      } else if (value.length > limit) {
        return '$fieldName 的長度不能超過 $limit';
      }

      return null;
    };
  }
}
