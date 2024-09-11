import 'package:flutter/material.dart';
import 'package:possystem/settings/language_setting.dart';

/// Show a date range picker dialog but with a slightly different design.
///
/// Human usually think 5/1~5/2 is two days.
/// Machine usually think 5/1~5/2 is one day (5/1 0:0 ~ 5/2 0:0).
/// So we need to convert between human and machine by adding a day to the end.
Future<DateTimeRange?> showMyDateRangePicker(BuildContext context, DateTimeRange range) async {
  final end = range.end.subtract(const Duration(days: 1));
  final now = DateTime.now();
  // TODO: using fullscreen and dialog
  final result = await showDateRangePicker(
    context: context,
    initialDateRange: DateTimeRange(
      start: range.start,
      // must be greater than [lastDate]
      end: end.microsecondsSinceEpoch > now.microsecondsSinceEpoch ? now : end,
    ),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    firstDate: DateTime(2021, 1),
    lastDate: now,
    locale: LanguageSetting.instance.language.locale,

    /// TODO: should fix this bug
    /// Wrapping the design, because the background will use a slightly
    /// transparent primary color when selecting a date, which will reduce
    /// the expected contrast, making it difficult to see, so adjust the color
    /// of onPrimary.
    builder: (context, dialog) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme.copyWith(
        onPrimary: theme.textTheme.bodyMedium?.color,
      );
      return Theme(
        data: theme.copyWith(colorScheme: colorScheme),
        child: dialog ?? const SizedBox.shrink(),
      );
    },
  );

  if (result != null) {
    return DateTimeRange(
      start: result.start,
      end: result.end.add(const Duration(days: 1)),
    );
  }

  return null;
}
