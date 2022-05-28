import 'package:uuid/uuid.dart';

class Util {
  static const uuid = Uuid();

  static String uuidV4() {
    return uuid.v4();
  }

  static int toUTC({int? hour, DateTime? now}) {
    now ??= getNow(hour: hour);

    return now.millisecondsSinceEpoch ~/ 1000;
  }

  static DateTime fromUTC(int utc) {
    return DateTime.fromMillisecondsSinceEpoch(utc * 1000);
  }

  static DateTime getNow({int? hour}) {
    final now = DateTime.now();
    if (hour != null) {
      return DateTime(now.year, now.month, now.day, hour);
    }

    return now;
  }

  static String removeExtension(String name) {
    final index = name.lastIndexOf('.');
    if (index == -1) {
      return name;
    }
    return name.substring(0, index);
  }
}
