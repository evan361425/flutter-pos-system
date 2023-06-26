import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/ui/exporter/order_range_info.dart';
import 'package:possystem/ui/exporter/export_order_loader.dart';

class ExporterOrderScreen extends StatelessWidget {
  final ValueNotifier<DateTimeRange> notifier;

  final orderLoader = GlobalKey<ExportOrderLoaderState>();

  ExporterOrderScreen({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrderRangeInfo(notifier: notifier),
        ListTile(
          title: const Text('約 3KB 的大小'),
          subtitle: const Text('複製過大的文字可能會造成系統的崩潰。'),
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
          child: ExportOrderLoader(
            key: orderLoader,
            notifier: notifier,
            formatOrder: (order) => Text(formatOrder(order)),
          ),
        ),
      ],
    );
  }

  Future<void> export() async {
    final orders = orderLoader.currentState?.orders;
    if (orders != null) {
      const exporter = PlainTextExporter();
      await exporter.exportToClipboard(orders
          .map((o) => [
                ExportOrderLoader.formatCreatedAt(o),
                ExportOrderLoader.formatHeader(o),
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
      '付額 ${order.paid.toCurrency()} 元、',
      '成分 ${order.cost.toCurrency()} 元\n',
      if (attributes != '') '顧客的$attributes。\n',
      '餐點有 $tc 份',
      if (pl != tc) '（$pl 種）',
      '包括：\n$products',
    ].join('');
  }
}
