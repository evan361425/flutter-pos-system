import 'dart:convert';

import 'package:possystem/helpers/db_transferer.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/services/database.dart';

class OrderObject {
  final int? id;

  /// 付額
  final num? paid;

  /// 總價，產品價錢+顧客設定價錢
  final num totalPrice;

  /// 產品價錢
  final num productsPrice;

  /// 產品總數
  final int totalCount;

  final List<String>? productNames;
  final List<String>? ingredientNames;

  /// 顧客設定，鍵代表種類，值代表選項
  final Map<String, String> customerSettings;
  final int? customerSettingsCombinationId;

  final Iterable<OrderProductObject> products;

  /// 點餐時間
  final DateTime createdAt;

  OrderObject({
    this.id,
    this.paid,
    required this.totalPrice,
    required this.productsPrice,
    required this.totalCount,
    this.productNames,
    this.ingredientNames,
    this.customerSettings = const {},
    this.customerSettingsCombinationId,
    required this.products,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  List<OrderProduct?> parseToProductWithNull() {
    return products.map<OrderProduct?>((orderProduct) {
      final product = Menu.instance.getProduct(orderProduct.productId);

      if (product == null) return null;

      return OrderProduct(
        product,
        count: orderProduct.count,
        singlePrice: orderProduct.singlePrice,
        selectedQuantity: {
          for (final item in orderProduct.ingredients.values)
            item.productIngredientId: item.productQuantityId
        },
      );
    }).toList();
  }

  List<OrderProduct> parseToProduct() {
    return parseToProductWithNull()
        .where((item) => item != null)
        .cast<OrderProduct>()
        .toList();
  }

  Map<String, Object?> toMap() {
    final usedIngredients = <String>[];

    for (var product in products) {
      for (var ingredient in product.ingredients.values) {
        usedIngredients.add(ingredient.name);
      }
    }

    return {
      'paid': paid,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'productsPrice': productsPrice,
      'createdAt': Util.toUTC(now: createdAt),
      'customerSettingCombinationId': customerSettingsCombinationId,
      'usedProducts': Database.join(
        products.map<String>((e) => e.productName),
      ),
      'usedIngredients': Database.join(usedIngredients),
      'encodedProducts': jsonEncode(
        products.map<Map<String, Object?>>((e) => e.toMap()).toList(),
      ),
    };
  }

  num get cost =>
      products.fold<num>(0.0, (total, product) => total + product.totalCost);

  /// 淨利
  num get income => totalPrice - cost;

  factory OrderObject.fromMap(Map<String, Object?> data) {
    final encodedProduct = data['encodedProducts'] as String?;
    final products = jsonDecode(encodedProduct ?? '[]') as List<dynamic>;
    final createdAt = data['createdAt'] == null
        ? null
        : Util.fromUTC(data['createdAt'] as int);
    final totalPrice = data['totalPrice'] as num? ?? 0;

    return OrderObject(
      createdAt: createdAt,
      id: data['id'] as int,
      paid: data['paid'] as num? ?? 0,
      totalPrice: totalPrice,
      totalCount: data['totalCount'] as int? ?? 0,
      productsPrice: data['productsPrice'] as num? ?? totalPrice,
      productNames: Database.split(data['usedProducts'] as String?),
      ingredientNames: Database.split(data['usedIngredients'] as String?),
      customerSettings:
          DBTransferer.parseCombination(data['combination'] as String?),
      products: products.map((product) => OrderProductObject.input(product)),
    );
  }
}

class OrderProductObject {
  final String productId;
  final String productName;

  /// 購買數量
  final int count;

  /// 單一成本，含份量的異動
  final num cost;

  /// 單一價格，含折扣的價格
  final num singlePrice;

  /// 單一原始價格
  final num originalPrice;

  /// 是否有折扣
  ///
  /// 折扣差可以做 method，如果有需要的話
  final bool isDiscount;

  final Map<String, OrderIngredientObject> ingredients;

  OrderProductObject({
    required this.productId,
    required this.productName,
    required this.count,
    required this.cost,
    required this.singlePrice,
    required this.originalPrice,
    required this.isDiscount,
    required this.ingredients,
  });

  num get totalPrice => count * singlePrice;

  num get totalCost => count * cost;

  Map<String, Object?> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'count': count,
      'cost': cost,
      'singlePrice': singlePrice,
      'originalPrice': originalPrice,
      'isDiscount': isDiscount,
      'ingredients': ingredients.values
          .map<Map<String, Object?>>(
            (e) => e.toMap(),
          )
          .toList(),
    };
  }

  factory OrderProductObject.input(Map<String, dynamic> data) {
    final ingredients =
        (data['ingredients'] ?? const Iterable.empty()) as Iterable<dynamic>;

    return OrderProductObject(
      productId: data['productId'] as String,
      productName: data['productName'] as String,
      count: data['count'] as int,
      cost: data['cost'] as int? ?? 0,
      singlePrice: data['singlePrice'] as num,
      originalPrice: data['originalPrice'] as num,
      isDiscount: data['isDiscount'] as bool,
      ingredients: {
        for (Map<String, dynamic> ingredient in ingredients)
          ingredient['id'] as String: OrderIngredientObject.input(ingredient)
      },
    );
  }
}

class OrderIngredientObject {
  /// 對應 stock 的 ID
  final String id;

  /// 對應產品的成分 ID
  final String productIngredientId;

  /// 成份名稱
  final String name;

  /// 對應 quantities 的 ID
  String? quantityId;

  /// 對應產品的份量 ID
  String? productQuantityId;
  String? quantityName;

  /// 因為份量影響的價錢
  num? additionalPrice;

  /// 因為份量影響的成本
  num? additionalCost;

  /// 成分最終數量，含份量的異動
  num amount;

  OrderIngredientObject({
    required this.id,
    required this.productIngredientId,
    required this.name,
    this.additionalPrice,
    this.additionalCost,
    required this.amount,
    this.productQuantityId,
    this.quantityId,
    this.quantityName,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'id': id,
      'productIngredientId': productIngredientId,
      'productQuantityId': productQuantityId,
      'additionalPrice': additionalPrice,
      'additionalCost': additionalCost,
      'amount': amount,
      'quantityId': quantityId,
      'quantityName': quantityName,
    };
  }

  factory OrderIngredientObject.input(Map<String, dynamic> data) {
    return OrderIngredientObject(
      name: data['name'] as String,
      id: data['id'] as String,
      // back compatible
      productIngredientId: data['productIngredientId'] ?? '',
      productQuantityId: data['productQuantityId'] ?? '',
      additionalPrice: data['additionalPrice'],
      additionalCost: data['additionalCost'],
      amount: data['amount'] ?? 0,
      quantityId: data['quantityId'],
      quantityName: data['quantityName'],
    );
  }

  factory OrderIngredientObject.fromModel(
    ProductIngredient ingredient,
    String? quantityId,
  ) {
    final quantity = quantityId == null ? null : ingredient.getItem(quantityId);

    return OrderIngredientObject(
      id: ingredient.ingredient.id,
      name: ingredient.name,
      productIngredientId: ingredient.id,
      productQuantityId: quantity?.id,
      amount: ingredient.amount + (quantity?.amount ?? 0),
      quantityId: quantity?.quantity.id,
      quantityName: quantity?.name,
      additionalCost: quantity?.additionalCost,
      additionalPrice: quantity?.additionalPrice,
    );
  }
}
