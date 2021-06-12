import 'package:sprintf/sprintf.dart';
import 'package:uuid/uuid.dart';

class Util {
  static final uuid = Uuid();

  static String uuidV4() {
    return uuid.v4();
  }

  static int toUTC({int? hour, DateTime? now}) {
    now ??= getNow(hour: hour);

    return now.millisecondsSinceEpoch ~/ 1000;
  }

  static DateTime fromUTC(int utc) {
    return DateTime.fromMillisecondsSinceEpoch(utc * 1000, isUtc: true);
  }

  static DateTime getNow({int? hour}) {
    final now = DateTime.now();
    if (hour != null) {
      return DateTime(now.year, now.month, now.day, hour);
    }

    return now;
  }

  static DateTime? parseDate(String? stringValue, [bool returnNull = false]) {
    try {
      return DateTime.parse(stringValue!);
    } catch (e) {
      return returnNull ? null : DateTime.now();
    }
  }

  static String? timeToDate(DateTime? time) {
    if (time == null) return null;
    return sprintf('%04d-%02d-%02d', [
      time.year,
      time.month,
      time.day,
    ]);
  }
}
