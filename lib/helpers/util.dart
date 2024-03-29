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

      if (!snapshot.hasData) {
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

extension PrettyNum on num {
  static final _format = NumberFormat.compact(locale: 'zh_TW');

  /// TODO: After currency is implemented, we need to change this to use currency formatter.
  /// 4.444     -> 4.44
  /// 44.44     -> 44.4
  /// 444.4     -> 444
  /// 4444      -> 4444
  /// 44444     -> 4.44萬
  /// 444444    -> 44.4萬
  /// 4444444   -> 444萬
  /// 44444444  -> 4444萬
  /// 444444444 -> 4.44億
  String prettyString() {
    return _format.format(this);
  }
}

extension RangeFormat on DateTimeRange {
  String format(DateFormat f) {
    return duration.inDays == 1
        ? f.format(start)
        : '${f.format(start)} - ${f.format(end.subtract(const Duration(days: 1)))}';
  }
}
