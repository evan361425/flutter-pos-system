import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/product_ingredient_model.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';

void main() {
  late ProductIngredientModel productIngredient;
  late ProductQuantityModel productQuantity;

  test('properties', () {
    final ingredient = OrderIngredientModel(
      ingredient: productIngredient,
      quantity: productQuantity,
    );

    expect(ingredient.amount, productQuantity.amount);
    expect(ingredient.cost, productQuantity.additionalCost);
    expect(ingredient.price, productQuantity.additionalPrice);
    expect(ingredient.id, productIngredient.id);
    expect('$ingredient', 'ham - less');
  });

  setUpAll(() {
    final ingredient = IngredientModel(name: 'ham', id: 'ing_1');
    final quantity = QuantityModel(name: 'less', id: 'qua_1');

    productIngredient = ProductIngredientModel(ingredient: ingredient);
    productQuantity = ProductQuantityModel(
      amount: 10,
      additionalCost: 20,
      additionalPrice: 30,
      quantity: quantity,
      ingredient: productIngredient,
    );
  });
}
