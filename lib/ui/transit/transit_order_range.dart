import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';

class TransitOrderRange extends StatefulWidget {
  final ValueNotifier<DateTimeRange> notifier;

  const TransitOrderRange({
    super.key,
    required this.notifier,
  });

  @override
  State<TransitOrderRange> createState() => _TransitOrderRangeState();
}

class _TransitOrderRangeState extends State<TransitOrderRange> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: const Key('btn.edit_range'),
      title: Text('${range.format(DateFormat.MMMd(S.localeName))} 的訂單'),
      subtitle: Text('${range.duration.inDays} 天的資料'),
      onTap: pickRange,
      trailing: const Icon(Icons.date_range_sharp),
    );
  }

  DateTimeRange get range => widget.notifier.value;

  /// 對人類來說 5/1~5/2 代表兩天
  /// 對機器來說 5/1~5/2 代表一天（5/1 0:0 ~ 5/2 0:0）
  /// 需要注意對機器和對人之間的轉換
  void pickRange() async {
    final result = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(
          start: range.start,
          end: range.end.subtract(const Duration(days: 1)),
        ),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        firstDate: DateTime(2021, 1),
        lastDate: DateTime.now(),
        locale: SettingsProvider.of<LanguageSetting>().value,
        // TODO: 應該會修掉這個 bug，需要注意
        // 另外包裝設計，因為選擇日期時，背景會使用有點半透明的 primary color
        // 這個會讓本來預期的對比降低，將會看不清楚，所以調整 onPrimary 的顏色。
        builder: (context, dialog) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme.copyWith(
            onPrimary: theme.textTheme.bodyMedium?.color,
          );
          return Theme(
            data: theme.copyWith(colorScheme: colorScheme),
            child: dialog ?? const SizedBox.shrink(),
          );
        });

    if (result != null) {
      _updateRange(result.start, result.end.add(const Duration(days: 1)));
    }
  }

  void _updateRange(DateTime start, DateTime end) {
    setState(() {
      widget.notifier.value = DateTimeRange(start: start, end: end);
    });
  }
}

extension RangeFormat on DateTimeRange {
  String format(DateFormat f) {
    return duration.inDays == 1
        ? f.format(start)
        : '${f.format(start)}-${f.format(end.subtract(const Duration(days: 1)))}';
  }
}
