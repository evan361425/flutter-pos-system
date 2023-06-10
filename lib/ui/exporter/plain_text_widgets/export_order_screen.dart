import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/ui/exporter/order_range_info.dart';
import 'package:possystem/ui/exporter/order_loader.dart';

class ExporterOrderScreen extends StatelessWidget {
  final DateTimeRange range;

  final orderLoader = GlobalKey<OrderLoaderState>();

  ExporterOrderScreen({
    Key? key,
    required this.range,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrderRangeInfo(
          range: range,
          trailing: ElevatedButton.icon(
            key: const Key('export_btn'),
            onPressed: () {
              showSnackbarWhenFailed(
                export(),
                context,
                'pt_export_failed',
              ).then((value) => showSnackBar(context, '複製成功'));
            },
            icon: const Icon(Icons.copy_outlined),
            label: const Text('複製文字'),
          ),
        ),
        Expanded(
          child: OrderLoader(
            key: orderLoader,
            range: range,
            formatOrder: (order) => Text(formatOrder(order)),
          ),
        ),
      ],
    );
  }

  Future<void> export() async {
    final state = orderLoader.currentState;
    if (state != null) {
      const exporter = PlainTextExporter();
      await exporter.exportToClipboard(state.orders
          .map((o) => [
                OrderLoader.formatCreatedAt(o),
                OrderLoader.formatHeader(o),
                formatOrder(o),
              ].join('\n'))
          .join('\n\n'));
    }
  }

  static String formatOrder(OrderObject order) {
    final attributes = order.attributes.map((a) {
      return '${a.name}為${a.optionName}';
    }).join('、');
    final products = order.products.map((p) {
      final ing = p.ingredients.map((i) {
        final amount = i.amount == 0 ? '' : '，使用 ${i.amount} 個';
        return '${i.name}（${i.quantityName ?? '預設份量'}$amount）';
      }).join('、 ');
      return [
        '點了 ${p.count} 份 ${p.productName}（${p.catalogName}）',
        '共 ${p.totalPrice.toCurrency()} 元',
        ing == '' ? '沒有設定成分' : '成份包括 $ing',
      ].join('');
    }).join('；\n');
    final pl = order.products.length;
    final tc = order.totalCount;

    return [
      if (order.productsPrice != order.totalPrice)
        '${order.totalPrice.toCurrency()} 元'
            '中的 ${order.productsPrice.toCurrency()} 元是產品價錢。\n',
      if (attributes != '') '顧客的$attributes。\n',
      '餐點有 $tc 份',
      if (pl != tc) '（$pl 種）',
      '包括：\n$products',
    ].join('');
  }
}
