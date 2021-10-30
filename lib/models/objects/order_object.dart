import 'dart:convert';

import 'package:possystem/helpers/db_transferer.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/services/database.dart';

class OrderObject {
  final int? id;
  final num? paid;
  final num totalPrice;
  final num productsPrice;
  final int totalCount;
  final List<String>? productNames;
  final List<String>? ingredientNames;
  final int? customerSettingsCombinationId;
  final DateTime createdAt;
  final Map<String, String> customerSettings;
  final Iterable<OrderProductObject> products;

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

  List<OrderProduct> parseToProduct() {
    return products
        .map<OrderProduct?>((orderProduct) {
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
        })
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
      // if fetching without these, it might be null
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
  final num singlePrice;
  final num originalPrice;
  final int count;
  final String productId;
  final String productName;
  final bool isDiscount;
  final Map<String, OrderIngredientObject> ingredients;

  OrderProductObject({
    required this.singlePrice,
    required this.originalPrice,
    required this.count,
    required this.productId,
    required this.productName,
    required this.isDiscount,
    required this.ingredients,
  });

  Map<String, Object?> toMap() {
    return {
      'singlePrice': singlePrice,
      'originalPrice': originalPrice,
      'count': count,
      'productId': productId,
      'productName': productName,
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
      singlePrice: data['singlePrice'] as num,
      originalPrice: data['originalPrice'] as num,
      count: data['count'] as int,
      productId: data['productId'] as String,
      productName: data['productName'] as String,
      isDiscount: data['isDiscount'] as bool,
      ingredients: {
        for (Map<String, dynamic> ingredient in ingredients)
          ingredient['id'] as String: OrderIngredientObject.input(ingredient)
      },
    );
  }
}

class OrderIngredientObject {
  final String id;
  final String name;
  final String productIngredientId;
  num? additionalPrice;
  num? additionalCost;
  num amount;
  String? productQuantityId;
  String? quantityId;
  String? quantityName;

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
