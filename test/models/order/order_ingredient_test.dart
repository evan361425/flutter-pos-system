import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/order/order_ingredient.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';

void main() {
  late ProductIngredient productIngredient;
  late ProductQuantity productQuantity;

  test('properties', () {
    final ingredient = OrderIngredient(
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
    final ingredient = Ingredient(name: 'ham', id: 'ing_1');
    final quantity = Quantity(name: 'less', id: 'qua_1');

    productIngredient = ProductIngredient(ingredient: ingredient);
    productQuantity = ProductQuantity(
      amount: 10,
      additionalCost: 20,
      additionalPrice: 30,
      quantity: quantity,
      ingredient: productIngredient,
    );
  });
}
