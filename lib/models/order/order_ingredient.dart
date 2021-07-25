import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';

class OrderIngredient {
  OrderIngredient({
    required this.ingredient,
    required this.quantity,
  });

  final ProductIngredient ingredient;
  final ProductQuantity quantity;

  num get amount => quantity.amount;
  num get price => quantity.additionalPrice;
  num get cost => quantity.additionalCost;

  String get id => ingredient.id;

  @override
  String toString() => '${ingredient.name} - ${quantity.name}';
}
