import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';

class OrderFormatter {
  static List<List<Object>> formatOrder(OrderObject order) {
    return [
      [
        order.createdAt.millisecondsSinceEpoch ~/ 1000,
        order.createdAt.toIso8601String(),
        order.totalPrice,
        order.productsPrice,
        order.paid,
        order.cost,
        order.totalCount,
        order.products.length,
        order.attributes
            .map((a) => [a.name, a.optionName].join(':'))
            .join('\n'),
        order.products
            .map((p) => [
                  p.productName,
                  p.catalogName,
                  p.count,
                  p.totalPrice.toCurrencyNum(),
                  p.cost.toCurrencyNum(),
                ].join(','))
            .join('\n'),
      ]
    ];
  }

  static List<List<Object>> formatOrderSetAttr(OrderObject order) {
    final createdAt = order.createdAt.millisecondsSinceEpoch ~/ 1000;
    return [
      for (final attr in order.attributes)
        if (attr.isNotEmpty)
          [
            createdAt,
            attr.name!,
            attr.optionName!,
          ],
    ];
  }

  static List<List<Object>> formatOrderProduct(OrderObject order) {
    final createdAt = order.createdAt.millisecondsSinceEpoch ~/ 1000;
    return [
      for (final product in order.products)
        [
          createdAt,
          product.productName,
          product.catalogName,
          product.count,
          product.singlePrice.toCurrencyNum(),
          product.cost.toCurrencyNum(),
          product.ingredients
              .map(
                (i) => [
                  i.name,
                  i.quantityName ?? '',
                  i.amount,
                ].join(','),
              )
              .join('\n'),
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
            ing.name,
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
    '總數',
    '總類',
    '顧客設定',
    '產品細項',
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
    '成份',
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
