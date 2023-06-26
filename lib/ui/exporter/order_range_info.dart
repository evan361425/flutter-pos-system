import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';

class OrderRangeInfo extends StatefulWidget {
  final ValueNotifier<DateTimeRange> notifier;

  const OrderRangeInfo({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  @override
  State<OrderRangeInfo> createState() => _OrderRangeInfoState();
}

class _OrderRangeInfoState extends State<OrderRangeInfo> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_title),
      subtitle: Text('${range.duration.inDays} 天的資料'),
      trailing: ElevatedButton.icon(
        key: const Key('edit_range_btn'),
        onPressed: pickRange,
        icon: const Icon(Icons.date_range_sharp),
        label: const Text('調整日期'),
      ),
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
    );

    if (result != null) {
      _updateRange(result.start, result.end.add(const Duration(days: 1)));
    }
  }

  void _updateRange(DateTime start, DateTime end) {
    setState(() {
      widget.notifier.value = DateTimeRange(start: start, end: end);
    });
  }

  String get _title {
    final f = DateFormat.MMMd(S.localeName);
    final duration = range.duration.inDays == 1
        ? f.format(range.start)
        : '${f.format(range.start)} - ${f.format(range.end.subtract(const Duration(days: 1)))}';

    return '$duration 的訂單';
  }
}
