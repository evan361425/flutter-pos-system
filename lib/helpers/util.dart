import 'package:flutter/material.dart';
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

  static DateTimeRange getDateRange({DateTime? now, int days = 1}) {
    now ??= DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(Duration(days: days));

    return DateTimeRange(start: start, end: end);
  }
}
