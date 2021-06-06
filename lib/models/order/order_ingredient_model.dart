import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';

class OrderIngredientModel {
  OrderIngredientModel({
    required this.ingredient,
    required this.quantity,
  });

  final ProductIngredientModel ingredient;
  final ProductQuantityModel quantity;

  num get amount => quantity.amount;
  num get price => quantity.additionalPrice;
  num get cost => quantity.additionalCost;

  String get id => ingredient.id;

  @override
  String toString() => '${ingredient.name} - ${quantity.name}';

  @override
  bool operator ==(Object other) {
    if (other is OrderIngredientModel) {
      return other.id == id;
    }
    return false;
  }
}
