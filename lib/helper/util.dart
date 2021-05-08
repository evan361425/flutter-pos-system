import 'package:sprintf/sprintf.dart';
import 'package:uuid/uuid.dart';

class Util {
  static final uuid = Uuid();

  static String uuidV4() {
    return uuid.v4();
  }

  static int similarity(String str1, String str2) {
    // starts with [searchText]
    var score =
        str1.split(' ').where((element) => element.startsWith(str2)).length * 2;
    // contains
    score += str1.contains(str2) ? 1 : 0;

    return score;
  }

  static DateTime parseDate(String stringValue, [bool returnNull = false]) {
    try {
      return DateTime.parse(stringValue);
    } catch (e) {
      return returnNull ? null : DateTime.now();
    }
  }

  static String timeToDate(DateTime time) {
    if (time == null) return null;
    return sprintf('%04d-%02d-%02d', [
      time.year,
      time.month,
      time.day,
    ]);
  }
}
