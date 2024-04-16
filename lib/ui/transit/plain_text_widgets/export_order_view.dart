import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/transit_order_list.dart';
import 'package:possystem/ui/transit/transit_order_range.dart';

class ExportOrderView extends StatelessWidget {
  final ValueNotifier<DateTimeRange> notifier;

  const ExportOrderView({
    super.key,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        Card(
          key: const Key('export_btn'),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTile(
            title: Text(S.transitPTCopyBtn),
            subtitle: Text(S.transitPTCopyWarning),
            trailing: const Icon(Icons.copy_outlined),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            onTap: () {
              showSnackbarWhenFailed(
                export(),
                context,
                'pt_export_failed',
              ).then((value) => showSnackBar(context, S.transitPTCopySuccess));
            },
          ),
        ),
        TransitOrderRange(notifier: notifier),
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
              S.transitOrderItemTitle(o.createdAt),
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
    return (m.count * 60 + m.attrCount! * 18 + m.productCount! * 25 + m.ingredientCount! * 10).toInt();
  }

  static String formatOrder(OrderObject order) {
    final attributes = order.attributes.map((a) {
      return S.transitPTFormatOrderOrderAttributeItem(a.name, a.optionName);
    }).join('、');
    final products = order.products.map((p) {
      final ing = p.ingredients.map((i) {
        return S.transitPTFormatOrderIngredient(
          i.amount,
          i.ingredientName,
          i.quantityName ?? S.transitPTFormatOrderNoQuantity,
        );
      }).join('、');
      return S.transitPTFormatOrderProduct(
        p.ingredients.length,
        p.productName,
        p.catalogName,
        p.count,
        p.totalPrice.toCurrency(),
        ing,
      );
    }).join('；\n');
    final pl = order.products.length;
    final tc = order.productsCount;

    return [
      S.transitPTFormatOrderPrice(
        order.productsPrice == order.price ? 0 : 1,
        order.price.toCurrency(),
        order.productsPrice.toCurrency(),
      ),
      S.transitPTFormatOrderMoney(order.paid.toCurrency(), order.cost.toCurrency()),
      if (attributes != '') S.transitPTFormatOrderOrderAttribute(attributes),
      S.transitPTFormatOrderProductCount(pl == tc ? 0 : 1, tc, pl, products)
    ].join('\n');
  }
}
