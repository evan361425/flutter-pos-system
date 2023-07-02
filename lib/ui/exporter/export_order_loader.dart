import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_loader.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class ExportOrderLoader extends StatelessWidget {
  final ValueNotifier<DateTimeRange> notifier;

  final Widget Function(OrderObject) formatOrder;

  const ExportOrderLoader({
    Key? key,
    required this.notifier,
    required this.formatOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrderLoader(
      calculateMemory: true,
      ranger: notifier,
      builder: _buildOrder,
    );
  }

  Widget _buildOrder(BuildContext context, OrderObject order) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(DateFormat.Hm(S.localeName).format(order.createdAt)),
      ),
      title: Text(DateFormat('M月d日 HH:mm:ss\n').format(order.createdAt)),
      subtitle: Text([
        '${order.totalCount} 份餐點',
        '共 ${order.totalPrice.toCurrency()} 元',
      ].join(MetaBlock.string)),
      trailing: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(title: const Text('訂單細節'), children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: formatOrder(order),
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
