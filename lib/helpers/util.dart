import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  static Widget Function(
    BuildContext context,
    AsyncSnapshot<T> snapshot,
  ) handleSnapshot<T>(Widget Function(BuildContext context, T? data) builder) {
    return (BuildContext context, AsyncSnapshot<T> snapshot) {
      final error = snapshot.error;
      if (error != null) {
        return Center(child: Text(error.toString()));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      return builder(context, snapshot.data);
    };
  }
}

extension RangeFormat on DateTimeRange {
  String format(String local) {
    final thisYear = DateTime.now().year;
    final fs = start.year == thisYear ? DateFormat.MMMd(local) : DateFormat.yMMMd(local);
    if (duration.inDays == 1) {
      return fs.format(start);
    }

    final fe = end.year == thisYear ? DateFormat.MMMd(local) : DateFormat.yMMMd(local);
    return '${fs.format(start)} - ${fe.format(end.subtract(const Duration(days: 1)))}';
  }

  String formatCompact(String local) {
    final thisYear = DateTime.now().year;
    final fs = start.year == thisYear ? DateFormat('MMdd', local) : DateFormat('yMMdd', local);
    if (duration.inDays == 1) {
      return fs.format(start);
    }

    final fe = end.year == thisYear ? DateFormat('MMdd', local) : DateFormat('yMMdd', local);
    return '${fs.format(start)} - ${fe.format(end.subtract(const Duration(days: 1)))}';
  }
}
