import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';

class OrderFormatter {
  static List<List<Object>> formatOrder(OrderObject order) {
    return [
      [
        Util.toUTC(now: order.createdAt),
        order.createdAt.toIso8601String(),
        order.price,
        order.productsPrice,
        order.paid,
        order.cost,
        order.profit,
        order.productsCount,
        order.products.length,
      ]
    ];
  }

  static List<List<Object>> formatOrderDetailsAttr(OrderObject order) {
    return [
      for (final attr in order.attributes)
        [
          Util.toUTC(now: order.createdAt),
          attr.name,
          attr.optionName,
        ],
    ];
  }

  static List<List<Object>> formatOrderDetailsProduct(OrderObject order) {
    return [
      for (final product in order.products)
        [
          Util.toUTC(now: order.createdAt),
          product.productName,
          product.catalogName,
          product.count,
          product.singlePrice.toCurrencyNum(),
          product.singleCost.toCurrencyNum(),
          product.originalPrice.toCurrencyNum(),
        ],
    ];
  }

  static List<List<Object>> formatOrderDetailsIngredient(OrderObject order) {
    final createdAt = order.createdAt.millisecondsSinceEpoch ~/ 1000;
    return [
      for (final product in order.products)
        for (final ing in product.ingredients)
          [
            createdAt,
            ing.ingredientName,
            ing.quantityName ?? '',
            ing.amount,
          ],
    ];
  }

  static List<String> get orderHeaders => [
        S.transitGSOrderHeaderTs,
        S.transitGSOrderHeaderTime,
        S.transitGSOrderHeaderPrice,
        S.transitGSOrderHeaderProductPrice,
        S.transitGSOrderHeaderPaid,
        S.transitGSOrderHeaderCost,
        S.transitGSOrderHeaderProfit,
        S.transitGSOrderHeaderItemCount,
        S.transitGSOrderHeaderTypeCount,
      ];

  /// Order's attributes at which index, 0-index
  static const orderDetailsAttrIndex = 8;

  /// Order's products detail at which index, 0-index
  static const orderDetailsProductIndex = 9;

  static List<String> get orderDetailsAttrHeaders => [
        S.transitGSOrderAttributeHeaderTs,
        S.transitGSOrderAttributeHeaderName,
        S.transitGSOrderAttributeHeaderOption,
      ];

  static List<String> get orderDetailsProductHeaders => [
        S.transitGSOrderProductHeaderTs,
        S.transitGSOrderProductHeaderName,
        S.transitGSOrderProductHeaderCatalog,
        S.transitGSOrderProductHeaderCount,
        S.transitGSOrderProductHeaderPrice,
        S.transitGSOrderProductHeaderCost,
        S.transitGSOrderProductHeaderOrigin,
      ];

  /// Order's ingredients detail at which index, 0-index
  static const orderDetailsIngredientIndex = 6;

  static List<String> get orderDetailsIngredientHeaders => [
        S.transitGSOrderIngredientHeaderTs,
        S.transitGSOrderIngredientHeaderName,
        S.transitGSOrderIngredientHeaderQuantity,
        S.transitGSOrderIngredientHeaderAmount,
      ];
}
