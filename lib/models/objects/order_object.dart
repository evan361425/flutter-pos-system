import 'package:flutter/material.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/menu_model.dart';

class OrderObject {
  final int id;
  num paid;
  final num totalPrice;
  final int totalCount;
  final DateTime createdAt;
  final Iterable<OrderProductObject> products;

  OrderObject({
    this.id,
    this.paid,
    this.totalPrice,
    this.totalCount,
    this.products,
    DateTime createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  List<OrderProductModel> parseToProduct() {
    return products
        .map<OrderProductModel>((productMap) {
          final product = MenuModel.instance.getProduct(productMap.productId);
          if (product == null) return null;

          final ingredients = <OrderIngredientModel>[];
          for (var object in productMap.ingredients.values) {
            if (object.quantityId == null) continue;

            final ingredient = product.getIngredient(object.ingredientId);

            ingredients.add(
              OrderIngredientModel(
                ingredient: ingredient,
                quantity: ingredient.getQuantity(object.quantityId),
              ),
            );
          }

          return OrderProductModel(
            product,
            count: productMap.count,
            singlePrice: productMap.singlePrice,
            ingredients: ingredients,
          );
        })
        .where((product) => product != null)
        .toList();
  }

  Map<String, Object> toMap() {
    return {
      'createdAt': createdAt,
      'paid': paid,
      'totalPrice': totalPrice,
      'totalCount': totalCount,
      'products': products.map((e) => e.toMap()).toList(),
    };
  }

  factory OrderObject.build(Map<String, Object> data) {
    if (data == null) return null;

    final List<Map<String, Object>> products = data['products'];

    return OrderObject(
      createdAt: data['createdAt'],
      id: data['id'],
      paid: data['paid'],
      totalPrice: data['totalPrice'],
      totalCount: data['totalCount'],
      products: products.map((product) => OrderProductObject.input(product)),
    );
  }
}

class OrderProductObject {
  final num singlePrice;
  final int count;
  final String productId;
  final String productName;
  final bool isDiscount;
  final Map<String, OrderIngredientObject> ingredients;

  OrderProductObject({
    @required this.singlePrice,
    @required this.count,
    @required this.productId,
    @required this.productName,
    @required this.isDiscount,
    @required this.ingredients,
  });

  Map<String, Object> toMap() {
    return {
      'singlePrice': singlePrice,
      'count': count,
      'productId': productId,
      'productName': productName,
      'isDiscount': isDiscount,
      'ingredients': ingredients.values
          .map<Map<String, Object>>(
            (e) => e.toMap(),
          )
          .toList(),
    };
  }

  factory OrderProductObject.input(Map<String, Object> data) {
    return OrderProductObject(
      singlePrice: data['singlePrice'],
      count: data['count'],
      productId: data['productId'],
      productName: data['productName'],
      isDiscount: data['isDiscount'],
      ingredients: {
        for (var ingredient in data['ingredients'])
          ingredient['ingredientId']: OrderIngredientObject.input(ingredient)
      },
    );
  }
}

class OrderIngredientObject {
  final String name;
  final String ingredientId;
  int price;
  int amount;
  String quantityId;

  OrderIngredientObject({
    @required this.name,
    @required this.ingredientId,
    this.price,
    @required this.amount,
    this.quantityId,
  });

  void update({
    @required price,
    @required amount,
    @required cost,
    @required quantityId,
  }) {
    this.price = price;
    this.amount = amount;
    this.quantityId = quantityId;
  }

  Map<String, Object> toMap() {
    return {
      'name': name,
      'ingredientId': ingredientId,
      'price': price,
      'amount': amount,
      'quantityId': quantityId,
    };
  }

  factory OrderIngredientObject.input(Map<String, Object> data) {
    return OrderIngredientObject(
      name: data['name'],
      ingredientId: data['ingredientId'],
      price: data['price'],
      amount: data['amount'],
      quantityId: data['quantityId'],
    );
  }
}
