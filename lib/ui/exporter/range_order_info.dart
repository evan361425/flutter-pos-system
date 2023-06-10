import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';

class RangeOrderInfo extends StatefulWidget {
  final DateTimeRange range;

  final Widget? trailing;

  const RangeOrderInfo({
    Key? key,
    required this.range,
    this.trailing,
  }) : super(key: key);

  @override
  State<RangeOrderInfo> createState() => _RangeOrderInfoState();

  static String rangeLabel(DateTimeRange range) {
    final format = DateFormat.yMMMd(S.localeName);
    return '${format.format(range.start)} - ${format.format(range.end)}';
  }
}

class _RangeOrderInfoState extends State<RangeOrderInfo> {
  int? totalCount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(RangeOrderInfo.rangeLabel(widget.range)),
      subtitle: MetaBlock.withString(context, [
        '${widget.range.duration.inDays} 天的資料',
        if (totalCount != null) '共 ${totalCount!} 個訂單',
      ]),
      trailing: widget.trailing,
    );
  }

  @override
  void initState() {
    super.initState();
    showSnackbarWhenFailed(
      Seller.instance
          .getMetricBetween(widget.range.start, widget.range.end)
          .then((value) {
        setState(() => totalCount = value['count']!.toInt());
      }),
      context,
      'export_load_order_count',
    );
  }
}
