import 'dart:convert';

import 'package:possystem/helper/util.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/services/database.dart';

class OrderObject {
  final int? id;
  num? paid;
  final num totalPrice;
  final int totalCount;
  final List<String>? productNames;
  final List<String>? ingredientNames;
  final DateTime createdAt;
  final Iterable<OrderProductObject> products;

  OrderObject({
    this.id,
    this.paid,
    required this.totalPrice,
    required this.totalCount,
    this.productNames,
    this.ingredientNames,
    required this.products,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  List<OrderProductModel> parseToProduct() {
    final data = products.map<OrderProductModel?>((productMap) {
      final product = MenuModel.instance.getProduct(productMap.productId);
      if (product == null) return null;

      final ingredients = <OrderIngredientModel>[];
      for (var object in productMap.ingredients.values) {
        if (object.quantityId == null) continue;

        final ingredient = product.getIngredient(object.id)!;

        ingredients.add(
          OrderIngredientModel(
            ingredient: ingredient,
            quantity: ingredient.getQuantity(object.quantityId)!,
          ),
        );
      }

      return OrderProductModel(
        product,
        count: productMap.count,
        singlePrice: productMap.singlePrice,
        ingredients: ingredients,
      );
    }).where((product) => product != null);

    return [for (final item in data) item!];
  }

  Map<String, Object?> toMap() {
    final usedIngredients = <String>[];

    products.forEach(
      (product) => product.ingredients.values.forEach(
        (ingredient) => usedIngredients.add(ingredient.name!),
      ),
    );

    return {
      'paid': paid,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'createdAt': Util.toUTC(now: createdAt),
      'usedProducts': Database.join(
        products.map<String>((e) => e.productName!),
      ),
      'usedIngredients': Database.join(usedIngredients),
      'encodedProducts': jsonEncode(
        products.map<Map<String, Object?>>((e) => e.toMap()).toList(),
      ),
    };
  }

  factory OrderObject.build(Map<String, Object?> data) {
    final encodedProduct = data['encodedProducts'] as String?;
    final products = jsonDecode(encodedProduct ?? '[]') as List<dynamic>;
    final createdAt = data['createdAt'] == null
        ? null
        : Util.fromUTC(data['createdAt'] as int);

    return OrderObject(
      createdAt: createdAt,
      id: data['id'] as int?,
      paid: data['paid'] as num?,
      // if fetching without this, it might be null
      totalPrice: data['totalPrice'] as num? ?? 0,
      totalCount: data['totalCount'] as int? ?? 0,
      productNames: Database.split(data['usedProducts'] as String?),
      ingredientNames: Database.split(data['usedIngredients'] as String?),
      products: products.map((product) => OrderProductObject.input(product)),
    );
  }
}

class OrderProductObject {
  final num? singlePrice;
  final int? count;
  final String? productId;
  final String? productName;
  final bool? isDiscount;
  final Map<String, OrderIngredientObject> ingredients;

  OrderProductObject({
    required this.singlePrice,
    required this.count,
    required this.productId,
    required this.productName,
    required this.isDiscount,
    required this.ingredients,
  });

  Map<String, Object?> toMap() {
    return {
      'singlePrice': singlePrice,
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

  @override
  String toString() => '$productName * $count';

  factory OrderProductObject.input(Map<String, dynamic> data) {
    final ingredients =
        (data['ingredients'] ?? Iterable.empty()) as Iterable<dynamic>;

    return OrderProductObject(
      singlePrice: data['singlePrice'] as num?,
      count: data['count'] as int?,
      productId: data['productId'] as String?,
      productName: data['productName'] as String?,
      isDiscount: data['isDiscount'] as bool?,
      ingredients: {
        for (Map<String, dynamic> ingredient in ingredients)
          ingredient['id'] as String: OrderIngredientObject.input(ingredient)
      },
    );
  }
}

class OrderIngredientObject {
  final String? name;
  final String? id;
  num? additionalPrice;
  num? additionalCost;
  num amount;
  String? quantityId;
  String? quantityName;

  OrderIngredientObject({
    required this.name,
    required this.id,
    this.additionalPrice,
    this.additionalCost,
    required this.amount,
    this.quantityId,
    this.quantityName,
  });

  void update({
    required num additionalPrice,
    required num additionalCost,
    required num amount,
    required String quantityId,
    required String quantityName,
  }) {
    this.additionalPrice = additionalPrice;
    this.additionalCost = additionalCost;
    // amount with special quantity
    this.amount = amount;
    // quantity info
    this.quantityId = quantityId;
    this.quantityName = quantityName;
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'id': id,
      'additionalPrice': additionalPrice,
      'additionalCost': additionalCost,
      'amount': amount,
      'quantityId': quantityId,
      'quantityName': quantityName,
    };
  }

  factory OrderIngredientObject.input(Map<String, dynamic> data) {
    return OrderIngredientObject(
      name: data['name'] as String?,
      id: data['id'] as String?,
      additionalPrice: data['additionalPrice'] as num?,
      additionalCost: data['additionalCost'] as num?,
      amount: data['amount'] as num? ?? 0,
      quantityId: data['quantityId'] as String?,
      quantityName: data['quantityName'] as String?,
    );
  }
}
