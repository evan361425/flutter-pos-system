import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';

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
        order.revenue,
        order.productsCount,
        order.products.length,
      ]
    ];
  }

  static List<List<Object>> formatOrderSetAttr(OrderObject order) {
    return [
      for (final attr in order.attributes)
        [
          Util.toUTC(now: order.createdAt),
          attr.name,
          attr.optionName,
        ],
    ];
  }

  static List<List<Object>> formatOrderProduct(OrderObject order) {
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

  static List<List<Object>> formatOrderIngredient(OrderObject order) {
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

  static const orderHeaders = [
    '時間戳記',
    '時間',
    '總價',
    '產品價錢',
    '付額',
    '成本',
    '收入',
    '產品總數',
    '產品種類',
  ];

  /// 顧客設定位於第幾個欄位，0-index
  static const orderSetAttrIndex = 8;

  /// 產品細項位於第幾個欄位，0-index
  static const orderProductIndex = 9;

  static const orderSetAttrHeaders = [
    '時間戳記',
    '設定類別',
    '選項',
  ];

  static const orderProductHeaders = [
    '時間戳記',
    '產品',
    '種類',
    '數量',
    '單一售價',
    '單一成本',
    '單一原價',
  ];

  /// 成份位於第幾個欄位，0-index
  static const orderIngredientIndex = 6;

  static const orderIngredientHeaders = [
    '時間戳記',
    '成份',
    '份量',
    '數量',
  ];
}
