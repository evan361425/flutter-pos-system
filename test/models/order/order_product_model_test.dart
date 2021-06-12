import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/order/order_ingredient_model.dart';
import 'package:possystem/models/order/order_product_model.dart';

import '../menu/product_ingredient_model_test.mocks.dart';
import '../menu/product_quantity_model_test.mocks.dart';
import 'order_product_model_test.mocks.dart';

MockOrderIngredientModel mockIngredient(String id, int price) {
  final ingredient = MockOrderIngredientModel();
  when(ingredient.id).thenReturn(id);
  when(ingredient.price).thenReturn(price);
  when(ingredient.toString()).thenReturn('');
  return ingredient;
}

@GenerateMocks([OrderIngredientModel])
void main() {
  test('properties', () {
    final product = MockProductModel();
    final ingredient1 = MockOrderIngredientModel();
    final ingredient2 = MockOrderIngredientModel();
    final order = OrderProductModel(
      product,
      count: 3,
      singlePrice: 5,
      ingredients: [ingredient1, ingredient2],
    );

    when(ingredient1.toString()).thenReturn('ing1');
    when(ingredient2.toString()).thenReturn('ing2');

    expect(order.ingredientNames.join(','), equals('ing1,ing2'));
    expect(order.price, equals(15));
  });

  group('#addIngredient', () {
    test('should have non-identical ingredient', () {
      final product = MockProductModel();
      final ingredient1 = mockIngredient('id', 2);
      final ingredient2 = mockIngredient('id', 1);
      final order = OrderProductModel(
        product,
        singlePrice: 5,
        ingredients: [ingredient1],
      );

      order.addIngredient(ingredient2);

      expect(order.singlePrice, equals(4));
      expect(identical(order.ingredients[0], ingredient1), isFalse);
      expect(order.ingredients.length, equals(1));
    });

    test('should push ingredient to back', () {
      final product = MockProductModel();
      final ingredient1 = mockIngredient('id1', 2);
      final ingredient2 = mockIngredient('id2', 2);
      final ingredient3 = mockIngredient('id1', 3);
      final order = OrderProductModel(
        product,
        singlePrice: 5,
        ingredients: [ingredient1, ingredient2],
      );

      order.addIngredient(ingredient3);

      expect(order.singlePrice, equals(6));
      expect(order.ingredients.length, equals(2));
      expect(identical(order.ingredients[0], ingredient2), isTrue);
      expect(identical(order.ingredients[1], ingredient3), isTrue);
    });
  });

  test('#increment, #decrement', () {
    final product = MockProductModel();
    final order = OrderProductModel(product, singlePrice: 5);

    order.increment(3);
    expect(order.count, equals(4));

    order.decrement(1);
    expect(order.count, equals(3));

    expect(order.price, equals(15));
  });

  test('#removeIngredient', () {
    final product = MockProductModel();
    final ingredient = mockIngredient('id', 2);
    final order =
        OrderProductModel(product, singlePrice: 10, ingredients: [ingredient]);

    order.removeIngredient('id');

    expect(order.ingredients, isEmpty);
    expect(order.singlePrice, equals(8));
  });

  test('#toggleSelected', () {
    final product = MockProductModel();
    final order = OrderProductModel(product, singlePrice: 10);

    order.toggleSelected();
    expect(order.isSelected, isTrue);

    order.toggleSelected();
    expect(order.isSelected, isFalse);

    order.toggleSelected(false);
    expect(order.isSelected, isFalse);
  });

  test('#toObject', () {
    MockProductIngredientModel mockProductIngredient(
      String id,
      String name,
      num amount,
    ) {
      final ingredient = MockProductIngredientModel();
      when(ingredient.id).thenReturn(id);
      when(ingredient.name).thenReturn(name);
      when(ingredient.amount).thenReturn(amount);
      return ingredient;
    }

    final ingredient1 = mockProductIngredient('id1', 'name1', 3);
    final ingredient2 = mockProductIngredient('id2', 'name2', 2);
    final ingredient3 = mockIngredient('id1', 5);
    final quantity = MockProductQuantityModel();

    when(quantity.id).thenReturn('q_id');
    when(quantity.name).thenReturn('q_name');
    when(ingredient3.cost).thenReturn(3);
    when(ingredient3.amount).thenReturn(5);
    when(ingredient3.quantity).thenReturn(quantity);

    final product = MockProductModel();
    when(product.id).thenReturn('p_id');
    when(product.name).thenReturn('p_name');
    when(product.price).thenReturn(10);
    when(product.ingredients).thenReturn({
      'id1': ingredient1,
      'id2': ingredient2,
    });

    final order = OrderProductModel(product, ingredients: [ingredient3]);
    final object = order.toObject();
    final ingredients = object.ingredients.values.toList();

    expect(object.singlePrice, equals(order.singlePrice));
    expect(object.count, equals(order.count));
    expect(object.productId, equals('p_id'));
    expect(object.productName, equals('p_name'));
    expect(object.originalPrice, equals(10 + 5));
    expect(object.isDiscount, isTrue);
    expect(
        ingredients[0].toMap(),
        equals({
          'name': 'name1',
          'id': 'id1',
          'additionalPrice': 5,
          'additionalCost': 3,
          'amount': 5, // replace product default amount by ordering
          'quantityId': 'q_id',
          'quantityName': 'q_name',
        }));
    expect(
        ingredients[1].toMap(),
        equals({
          'name': 'name2',
          'id': 'id2',
          'additionalPrice': null,
          'additionalCost': null,
          'amount': 2,
          'quantityId': null,
          'quantityName': null,
        }));
  });
}
