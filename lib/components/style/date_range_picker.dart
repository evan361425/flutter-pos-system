import 'package:flutter/material.dart';
import 'package:possystem/settings/language_setting.dart';

/// Show a date range picker dialog but with a slightly different design.
///
/// Human usually think 5/1-5/2 is two days.
/// Machine usually think 5/1-5/2 is one day (5/1 0:0 ~ 5/2 0:0).
/// So we need to convert between human and machine by adding a day to the end.
Future<DateTimeRange?> showMyDateRangePicker(BuildContext context, DateTimeRange range) async {
  final end = range.end.subtract(const Duration(days: 1));
  final now = DateTime.now();
  final size = MediaQuery.sizeOf(context);
  final result = await showDateRangePicker(
    context: context,
    initialDateRange: DateTimeRange(
      start: range.start,
      // must greater than [lastDate]
      end: end.microsecondsSinceEpoch > now.microsecondsSinceEpoch ? now : end,
    ),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    firstDate: DateTime(2021, 1),
    lastDate: now,
    locale: LanguageSetting.instance.language.locale,
    builder: size.width < 840 || size.height < 600
        ? null
        : (context, child) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  margin: const EdgeInsets.all(12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560, maxHeight: 540),
                    child: child,
                  ),
                ),
              ],
            ),
  );

  if (result != null) {
    return DateTimeRange(
      start: result.start,
      end: result.end.add(const Duration(days: 1)),
    );
  }

  return null;
}
