import 'package:flutter/material.dart';
import 'package:possystem/components/style/date_range_picker.dart';
import 'package:possystem/helpers/util.dart';
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
      title: Text(S.transitOrderMetaRange(range.format(S.localeName))),
      subtitle: Text(S.transitOrderMetaRangeDays(range.duration.inDays)),
      onTap: pickRange,
      trailing: const Icon(Icons.date_range_outlined),
    );
  }

  DateTimeRange get range => widget.notifier.value;

  void pickRange() async {
    final result = await showMyDateRangePicker(context, range);

    if (result != null) {
      _updateRange(result.start, result.end);
    }
  }

  void _updateRange(DateTime start, DateTime end) {
    setState(() {
      widget.notifier.value = DateTimeRange(start: start, end: end);
    });
  }
}
