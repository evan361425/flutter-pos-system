import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';
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
    final orders = await Seller.instance.getDetailedOrders(
      notifier.value.start,
      notifier.value.end,
    );

    const exporter = PlainTextExporter();
    await exporter.exportToClipboard(orders
        .map((o) => [
              DateFormat('M月d日 HH:mm:ss').format(o.createdAt),
              formatOrder(o),
            ].join('\n'))
        .join('\n\n'));
  }

  /// 實際輸出結果：
  ///
  /// 共 110 元，其中的 90 元是產品價錢。
  /// 付額 150 元、成分 30 元。
  /// 顧客的 用餐位置 為 內用、年紀 為 三十歲。
  /// 餐點有 3 份（2 種）包括：
  /// 起士漢堡（漢堡）1 份共 200 元，成份包括
  /// 起士（多量，使用 3 個）。
  static int memoryPredictor(OrderMetrics m) {
    return (m.count * 60 +
            m.attrCount! * 18 +
            m.productCount! * 25 +
            m.ingredientCount! * 10)
        .toInt();
  }

  static String formatOrder(OrderObject order) {
    final attributes = order.attributes.map((a) {
      return '${a.name} 為 ${a.optionName}';
    }).join('、');
    final products = order.products.map((p) {
      final ing = p.ingredients.map((i) {
        final amount = i.amount == 0 ? '' : '，使用 ${i.amount} 個';
        return S.orderProductIngredientName(
          i.ingredientName,
          (i.quantityName ?? '預設份量') + amount,
        );
      }).join('、');
      return [
        '${p.productName}（${p.catalogName}）',
        '${p.count} 份共 ${p.totalPrice.toCurrency()} 元，',
        ing == '' ? '沒有設定成分' : '成份包括 $ing',
      ].join('');
    }).join('；\n');
    final pl = order.products.length;
    final tc = order.productsCount;

    return [
      '共 ${order.price.toCurrency()} 元',
      order.productsPrice == order.price
          ? '。\n'
          : '，其中的 ${order.productsPrice.toCurrency()} 元是產品價錢。\n',
      '付額 ${order.paid.toCurrency()} 元、',
      '成分 ${order.cost.toCurrency()} 元。\n',
      if (attributes != '') '顧客的 $attributes。\n',
      '餐點有 $tc 份',
      if (pl != tc) '（$pl 種）',
      '包括：\n$products。',
    ].join('');
  }
}
