import 'package:possystem/localizations.dart';

class Validator {
  static Local tranlator;

  static String Function(String) positiveDouble(String fieldName) {
    return (String value) {
      try {
        if (double.parse(value) < 0) {
          return '$fieldName不能為負數';
        }
      } catch (err) {
        return '$fieldName必須是數字';
      }
      return null;
    };
  }

  static String Function(String) isDouble(String fieldName) {
    return (String value) {
      try {
        double.parse(value);
      } catch (err) {
        return '$fieldName必須是數字';
      }
      return null;
    };
  }

  static String Function(String) textLimit(String fieldName, int limit) {
    return (String value) {
      try {
        if (value.isEmpty) {
          return '$fieldName不能為空';
        }

        if (value.length > limit) {
          return '$fieldName的長度不能超過$limit';
        }
      } catch (err) {
        return '發生無法預期的錯誤..';
      }
      return null;
    };
  }
}
