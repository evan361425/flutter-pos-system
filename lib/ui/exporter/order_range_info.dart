import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';

class OrderRangeInfo extends StatefulWidget {
  final DateTimeRange range;

  final Widget? trailing;

  const OrderRangeInfo({
    Key? key,
    required this.range,
    this.trailing,
  }) : super(key: key);

  @override
  State<OrderRangeInfo> createState() => _OrderRangeInfoState();
}

class _OrderRangeInfoState extends State<OrderRangeInfo> {
  int? totalCount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.range.format()),
      subtitle: MetaBlock.withString(context, [
        '${widget.range.duration.inDays + 1} 天的資料',
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

extension DateTimeRangeFormat on DateTimeRange {
  String format() {
    final f = DateFormat.yMMMd(S.localeName);
    return '${f.format(start)} 到 ${f.format(end)}';
  }
}
