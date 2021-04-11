import 'package:possystem/localizations.dart';

class Validator {
  static Local tranlator;

  static String Function(String) positiveNumber(
    String fieldName, {
    num maximum,
  }) {
    return (String value) {
      try {
        final number = num.parse(value);
        if (number < 0) {
          return '$fieldName 不能為負數';
        } else if (maximum != null && maximum < number) {
          return '$fieldName 不能大於 $maximum';
        }

        return null;
      } catch (err) {
        return '$fieldName 必須是數字';
      }
    };
  }

  static String Function(String) isNumber(String fieldName) {
    return (String value) {
      try {
        num.parse(value);

        return null;
      } catch (err) {
        return '$fieldName 必須是數字';
      }
    };
  }

  static String Function(String) textLimit(String fieldName, int limit) {
    return (String value) {
      try {
        if (value.isEmpty) {
          return '$fieldName 不能為空';
        } else if (value.length > limit) {
          return '$fieldName 的長度不能超過 $limit';
        }

        return null;
      } catch (err) {
        return '發生無法預期的錯誤..';
      }
    };
  }
}
