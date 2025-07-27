import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';

class OrderFormatter {
  static List<List<CellData>> formatBasic(OrderObject order) {
    return [
      [
        CellData(number: order.periodSeq),
        CellData(string: order.createdAt.toIso8601String()),
        CellData(number: order.price),
        CellData(number: order.productsPrice),
        CellData(number: order.paid),
        CellData(number: order.cost),
        CellData(number: order.profit),
        CellData(number: order.productsCount),
        CellData(number: order.products.length),
      ]
    ];
  }

  static List<List<CellData>> formatAttr(OrderObject order) {
    return [
      for (final attr in order.attributes)
        [
          CellData(number: order.periodSeq),
          CellData(string: attr.name),
          CellData(string: attr.optionName),
        ],
    ];
  }

  static List<List<CellData>> formatProduct(OrderObject order) {
    return [
      for (final product in order.products)
        [
          CellData(number: order.periodSeq),
          CellData(string: product.productName),
          CellData(string: product.catalogName),
          CellData(number: product.count),
          CellData(number: product.singlePrice.toCurrencyNum()),
          CellData(number: product.singleCost.toCurrencyNum()),
          CellData(number: product.originalPrice.toCurrencyNum()),
        ],
    ];
  }

  static List<List<CellData>> formatIngredient(OrderObject order) {
    return [
      for (final product in order.products)
        for (final ing in product.ingredients)
          [
            CellData(number: order.periodSeq),
            CellData(string: ing.ingredientName),
            CellData(string: ing.quantityName ?? ''),
            CellData(number: ing.amount),
          ],
    ];
  }

  static List<String> get basicHeaders => [
        S.transitFormatFieldOrderNo,
        S.transitFormatFieldOrderTime,
        S.transitFormatFieldOrderPrice,
        S.transitFormatFieldOrderProductPrice,
        S.transitFormatFieldOrderPaid,
        S.transitFormatFieldOrderCost,
        S.transitFormatFieldOrderProfit,
        S.transitFormatFieldOrderItemCount,
        S.transitFormatFieldOrderTypeCount,
      ];

  /// Order's attributes at which index, 0-index
  static const attrPosition = 8;

  /// Order's products detail at which index, 0-index
  static const productPosition = 9;

  static List<String> get attrHeaders => [
        S.transitFormatFieldOrderAttributeHeaderNo,
        S.transitFormatFieldOrderAttributeHeaderName,
        S.transitFormatFieldOrderAttributeHeaderOption,
      ];

  static List<String> get productHeaders => [
        S.transitFormatFieldOrderProductHeaderNo,
        S.transitFormatFieldOrderProductHeaderName,
        S.transitFormatFieldOrderProductHeaderCatalog,
        S.transitFormatFieldOrderProductHeaderCount,
        S.transitFormatFieldOrderProductHeaderPrice,
        S.transitFormatFieldOrderProductHeaderCost,
        S.transitFormatFieldOrderProductHeaderOrigin,
      ];

  /// Order's ingredients detail at which index, 0-index
  static const ingredientPosition = 6;

  static List<String> get ingredientHeaders => [
        S.transitFormatFieldOrderIngredientHeaderNo,
        S.transitFormatFieldOrderIngredientHeaderName,
        S.transitFormatFieldOrderIngredientHeaderQuantity,
        S.transitFormatFieldOrderIngredientHeaderAmount,
      ];
}
