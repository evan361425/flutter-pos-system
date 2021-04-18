import 'package:flutter/foundation.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';

class OrderIngredientModel {
  OrderIngredientModel({
    @required this.ingredient,
    @required this.quantity,
    @required this.ingredientName,
    @required this.quantityName,
  });

  final ProductIngredientModel ingredient;
  final ProductQuantityModel quantity;
  final String ingredientName;
  final String quantityName;

  String get id => ingredient.id;

  @override
  String toString() => '$ingredientName - $quantityName';

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
