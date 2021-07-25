import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/order/order_ingredient.dart';
import 'package:possystem/models/order/order_product.dart';

import '../../mocks/mock_models.mocks.dart';

void main() {
  MockOrderIngredient mockIngredient(String id, int price) {
    final ingredient = MockOrderIngredient();
    when(ingredient.id).thenReturn(id);
    when(ingredient.price).thenReturn(price);
    return ingredient;
  }

  test('properties', () {
    final product = MockProduct();
    final pIng1 = MockProductIngredient();
    final pIng2 = MockProductIngredient();
    final pQua = MockProductQuantity();
    final ingredient1 = OrderIngredient(ingredient: pIng1, quantity: pQua);
    final ingredient2 = OrderIngredient(ingredient: pIng2, quantity: pQua);
    final order = OrderProduct(
      product,
      count: 3,
      singlePrice: 5,
      ingredients: [ingredient1, ingredient2],
    );

    when(pIng1.name).thenReturn('ing1');
    when(pIng2.name).thenReturn('ing2');
    when(pQua.name).thenReturn('qua');

    expect(order.ingredientNames.join(','), equals('ing1 - qua,ing2 - qua'));
    expect(order.price, equals(15));
  });

  group('#addIngredient', () {
    test('should have non-identical ingredient', () {
      final product = MockProduct();
      final ingredient1 = mockIngredient('id', 2);
      final ingredient2 = mockIngredient('id', 1);
      final order = OrderProduct(
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
      final product = MockProduct();
      final ingredient1 = mockIngredient('id1', 2);
      final ingredient2 = mockIngredient('id2', 2);
      final ingredient3 = mockIngredient('id1', 3);
      final order = OrderProduct(
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
    final product = MockProduct();
    final order = OrderProduct(product, singlePrice: 5);

    order.increment(3);
    expect(order.count, equals(4));

    order.decrement(1);
    expect(order.count, equals(3));

    expect(order.price, equals(15));
  });

  test('#removeIngredient', () {
    final product = MockProduct();
    final ingredient = mockIngredient('id', 2);
    final order =
        OrderProduct(product, singlePrice: 10, ingredients: [ingredient]);

    order.removeIngredient('id');

    expect(order.ingredients, isEmpty);
    expect(order.singlePrice, equals(8));
  });

  test('#toggleSelected', () {
    final product = MockProduct();
    final order = OrderProduct(product, singlePrice: 10);

    order.toggleSelected();
    expect(order.isSelected, isTrue);

    order.toggleSelected();
    expect(order.isSelected, isFalse);

    order.toggleSelected(false);
    expect(order.isSelected, isFalse);
  });

  test('#toObject', () {
    MockProductIngredient mockProductIngredient(
      String id,
      String name,
      num amount,
    ) {
      final ingredient = MockProductIngredient();
      when(ingredient.id).thenReturn(id);
      when(ingredient.name).thenReturn(name);
      when(ingredient.amount).thenReturn(amount);
      return ingredient;
    }

    final ingredient1 = mockProductIngredient('id1', 'name1', 3);
    final ingredient2 = mockProductIngredient('id2', 'name2', 2);
    final ingredient3 = mockIngredient('id1', 5);
    final quantity = MockProductQuantity();

    when(quantity.id).thenReturn('q_id');
    when(quantity.name).thenReturn('q_name');
    when(ingredient3.cost).thenReturn(3);
    when(ingredient3.amount).thenReturn(5);
    when(ingredient3.quantity).thenReturn(quantity);

    final product = Product(
        ingredients: {'id1': ingredient1, 'id2': ingredient2},
        id: 'p_id',
        name: 'p_name',
        price: 10,
        cost: 5,
        index: 1);
    // when(product.getChild('id1')).thenReturn(ingredient1);
    // when(product.getChild('id2')).thenReturn(ingredient2);

    final order = OrderProduct(product, ingredients: [ingredient3]);
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
