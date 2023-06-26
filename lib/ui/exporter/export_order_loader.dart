import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_loader.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class ExportOrderLoader extends StatefulWidget {
  final ValueNotifier<DateTimeRange> notifier;

  final Widget Function(OrderObject) formatOrder;

  const ExportOrderLoader({
    Key? key,
    required this.notifier,
    required this.formatOrder,
  }) : super(key: key);

  @override
  State<ExportOrderLoader> createState() => ExportOrderLoaderState();

  static String formatCreatedAt(OrderObject order) {
    return '${DateFormat.MMMd(S.localeName).format(order.createdAt)} ${DateFormat.Hms(S.localeName).format(order.createdAt)}';
  }

  static String formatHeader(OrderObject order) {
    return [
      '${order.totalCount} 份餐點',
      '共 ${order.totalPrice.toCurrency()} 元',
    ].join(MetaBlock.string);
  }
}

class ExportOrderLoaderState extends State<ExportOrderLoader> {
  final loaderKey = OrderLoader.createKey();

  @override
  Widget build(BuildContext context) {
    return OrderLoader(
      loaderKey: loaderKey,
      ranger: () => widget.notifier.value,
      builder: _buildOrder,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onRangeChanged);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onRangeChanged);
    super.dispose();
  }

  void _onRangeChanged() {
    loaderKey.currentState?.reset();
  }

  List<OrderObject>? get orders => loaderKey.currentState?.items;

  Widget _buildOrder(OrderObject order) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(DateFormat.Hm(S.localeName).format(order.createdAt)),
      ),
      title: Text(ExportOrderLoader.formatCreatedAt(order)),
      subtitle: Text(ExportOrderLoader.formatHeader(order)),
      trailing: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(title: const Text('訂單細節'), children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.formatOrder(order),
                ),
              ]);
            },
          );
        },
        child: const Text('細節'),
      ),
    );
  }
}
