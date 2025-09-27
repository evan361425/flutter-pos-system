import 'package:flutter/material.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/plain_text_exporter.dart';
import 'package:possystem/ui/transit/order_widgets.dart';

class ExportOrderHeader extends TransitOrderHeader {
  const ExportOrderHeader({
    super.key,
    required super.stateNotifier,
    required super.ranger,
    super.settings,
  });

  @override
  String get title => S.transitExportOrderTitlePlainText;

  @override
  Future<void> onExport(BuildContext context, List<OrderObject> orders) async {
    await const PlainTextExporter().exportToClipboard(orders
        .map((o) => [
              o.createDateTimeString,
              ExportOrderView.formatOrder(o),
            ].join('\n'))
        .join('\n\n'));

    if (context.mounted) {
      showSnackBar(S.transitExportOrderSuccessPlainText, context: context);
    }
  }
}

class ExportOrderView extends TransitOrderList {
  const ExportOrderView({
    super.key,
    required super.ranger,
  });

  @override
  String get helpMessage => S.transitExportOrderSubtitlePlainText;

  @override
  int memoryPredictor(OrderMetrics metrics) => _memoryPredictor(metrics);

  @override
  Widget buildOrderView(BuildContext context, OrderObject order) {
    return Text(formatOrder(order));
  }

  /// Actual result depends on language, here is English version:
  ///
  /// Total $110, $90 of them are product price.
  /// Paid $150, cost $30.
  /// Customer's dining location is Dine-in, age is 30.
  /// There are 3 (2 kinds) products including:
  /// Cheese Burger (Burger) 1, total $200, ingredients are Cheese (Large, use 3).
  static int _memoryPredictor(OrderMetrics m) {
    return (m.count * 60 + m.attrCount! * 18 + m.productCount! * 25 + m.ingredientCount! * 10).toInt();
  }

  static String formatOrder(OrderObject order) {
    final attributes = order.attributes.map((a) {
      return S.transitFormatTextOrderOrderAttributeItem(a.name, a.optionName);
    }).join('、');
    final products = order.products.map((p) {
      final ing = p.ingredients.map((i) {
        return S.transitFormatTextOrderIngredient(
          i.amount,
          i.ingredientName,
          i.quantityName ?? S.transitFormatTextOrderNoQuantity,
        );
      }).join('、');
      return S.transitFormatTextOrderProduct(
        p.ingredients.length,
        p.productName,
        p.catalogName,
        p.count,
        p.totalPrice.toCurrency(),
        ing,
      );
    }).join('；\n');
    final setCount = order.products.length;
    final totalCount = order.productsCount;

    return [
      S.transitFormatTextOrderPrice(
        order.productsPrice == order.price ? 0 : 1,
        order.price.toCurrency(),
        order.productsPrice.toCurrency(),
      ),
      S.transitFormatTextOrderMoney(order.paid.toCurrency(), order.cost.toCurrency()),
      if (attributes != '') S.transitFormatTextOrderOrderAttribute(attributes),
      S.transitFormatTextOrderProductCount(totalCount, setCount, products)
    ].join('\n');
  }
}
