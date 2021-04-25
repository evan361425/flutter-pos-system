import 'package:flutter/foundation.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';

class OrderIngredientModel {
  OrderIngredientModel({
    @required this.ingredient,
    @required this.quantity,
  });

  final ProductIngredientModel ingredient;
  final ProductQuantityModel quantity;

  Map<String, dynamic> toMap() {
    final result = quantity.toMap();
    result['name'] = quantity.quantity.name;
    return result;
  }

  num get amount => quantity.amount;
  num get price => quantity.additionalPrice;
  num get cost => ingredient.cost + quantity.additionalCost;

  String get id => ingredient.id;

  @override
  String toString() =>
      '${ingredient.ingredient.name} - ${quantity.quantity.name}';

  @override
  bool operator ==(Object other) {
    if (other is OrderIngredientModel) {
      return other.id == id;
    } else if (other is ProductIngredientModel) {
      return other.id == id;
    }
    return false;
  }
}
