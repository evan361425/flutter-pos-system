import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/ui/transit/transit_order_range.dart';
import 'package:possystem/ui/transit/transit_order_list.dart';

class ExportOrderView extends StatelessWidget {
  final ValueNotifier<DateTimeRange> notifier;

  const ExportOrderView({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TransitOrderRange(notifier: notifier),
        ListTile(
          key: const Key('export_btn'),
          title: const Text('複製文字'),
          subtitle: const Text('複製過大的文字可能會造成系統的崩潰'),
          trailing: const Icon(Icons.copy_outlined),
          onTap: () {
            showSnackbarWhenFailed(
              export(),
              context,
              'pt_export_failed',
            ).then((value) => showSnackBar(context, '複製成功'));
          },
        ),
        Expanded(
          child: TransitOrderList(
            notifier: notifier,
            formatOrder: (order) => Text(formatOrder(order)),
            memoryPredictor: memoryPredictor,
          ),
        ),
      ],
    );
  }

  Future<void> export() async {
    final orders = await Seller.instance.getOrders(
      notifier.value.start,
      notifier.value.end,
      limit: null,
    );

    const exporter = PlainTextExporter();
    await exporter.exportToClipboard(orders
        .map((o) => [
              DateFormat('M月d日 HH:mm:ss').format(o.createdAt),
              formatOrder(o),
            ].join('\n'))
        .join('\n\n'));
  }

  /// 產品文字較多。
  ///
  /// 這裡是一些實測的大小對應值：
  /// | productSize | attrSize | count | bytes | actual |
  /// | - | - | - | - |
  /// | 13195 | 34 | 17 | 6439 | 6.1KB |
  /// | 39672 | 92 | 46 | 18758 | 18KB |
  /// | 61751 | 142 | 71 | 29043 | 28KB |
  /// | 83775 | 200 | 100 | 39771 | 38KB |
  static int memoryPredictor(OrderMetrics m) {
    return (m.productCount! * 0.435 + m.attrCount! * 0.3 + 30 * m.count)
        .toInt();
  }

  static String formatOrder(OrderObject order) {
    final attributes = order.attributes.map((a) {
      return '${a.name}為${a.optionName}';
    }).join('、');
    final products = order.products.map((p) {
      final ing = p.ingredients.map((i) {
        final amount = i.amount == 0 ? '' : '，使用 ${i.amount} 個';
        return '${i.ingredientName}（${i.isDefaultQuantity ? '預設份量' : i.quantityName}$amount）';
      }).join('、 ');
      return [
        '${p.productName}（${p.catalogName}）',
        '${p.count} 份共 ${p.totalPrice.toCurrency()} 元',
        ing == '' ? '沒有設定成分' : '成份包括 $ing',
      ].join('');
    }).join('；\n');
    final pl = order.products.length;
    final tc = order.productsCount;

    return [
      '共 ${order.price.toCurrency()} 元',
      order.productsPrice == order.price
          ? '\n'
          : '，其中的 ${order.productsPrice.toCurrency()} 元是產品價錢。\n',
      '付額 ${order.paid.toCurrency()} 元、',
      '成分 ${order.cost.toCurrency()} 元\n',
      if (attributes != '') '顧客的$attributes。\n',
      '餐點有 $tc 份',
      if (pl != tc) '（$pl 種）',
      '包括：\n$products。',
    ].join('');
  }
}
