import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/objects/order_object.dart';

import '../../mocks/mockito/mock_product_model.dart';
import '../../mocks/mocks.dart';
import '../menu/product_ingredient_model_test.mocks.dart';
import '../menu/product_quantity_model_test.mocks.dart';
import '../repository/stock_model_test.mocks.dart';

void main() {
  test('#parseToProduct', () {
    MockOrderProductObject createProduct(
      String id,
      int count,
      num price,
      Map<String, String?> ingredients,
    ) {
      final orderProduct = MockOrderProductObject();
      final product = MockProductModel();
      final orderIngredients = <String, MockOrderIngredientObject>{};

      when(orderProduct.productId).thenReturn(id);
      when(orderProduct.ingredients).thenReturn(orderIngredients);
      when(orderProduct.count).thenReturn(count);
      when(orderProduct.singlePrice).thenReturn(price);
      when(menu.getProduct(id)).thenReturn(product);

      ingredients.forEach((ingredientId, quantityId) {
        final orderIngredient = MockOrderIngredientObject();
        final ingredient = MockProductIngredientModel();
        final quantity = MockProductQuantityModel();

        when(orderIngredient.id).thenReturn(ingredientId);
        when(orderIngredient.quantityId).thenReturn(quantityId);
        when(product.getItem(ingredientId)).thenReturn(ingredient);
        when(ingredient.getItem(quantityId)).thenReturn(quantity);

        orderIngredients[ingredientId] = orderIngredient;
      });

      return orderProduct;
    }

    final order = OrderObject(totalCount: 1, totalPrice: 1, products: [
      createProduct('pdt_1', 1, 2, {'igt_1': 'qty_1', 'igt_2': 'qty_1'}),
      createProduct('pdt_2', 3, 4, {'igt_2': 'qty_2'}),
    ]);

    final products = order.parseToProduct();

    expect(products[0].count, 1);
    expect(products[0].singlePrice, 2);
    expect(products[0].ingredients.length, 2);
    expect(products[1].count, 3);
    expect(products[1].singlePrice, 4);
    expect(products[1].ingredients.length, 1);
  });

  test('map object transfer', () {
    final object = OrderObject(
        id: 1,
        totalPrice: 10,
        totalCount: 5,
        paid: 50,
        createdAt: DateTime.now(),
        products: [
          OrderProductObject(
              singlePrice: 10,
              originalPrice: 20,
              count: 2,
              productId: 'pdt_1',
              productName: 'pdt_1-name',
              isDiscount: true,
              ingredients: {
                'igt_1': OrderIngredientObject(
                    id: 'igt_1', name: 'igt_1-name', amount: 5),
                'igt_2': OrderIngredientObject(
                    id: 'igt_2',
                    name: 'igt_2-name',
                    amount: 5,
                    additionalCost: 5,
                    additionalPrice: 10,
                    quantityId: 'qty_1',
                    quantityName: 'qty_1-name')
              }),
          OrderProductObject(
              singlePrice: 2,
              originalPrice: 3,
              count: 4,
              productId: 'pdt_2',
              productName: 'pdt_2-name',
              isDiscount: false,
              ingredients: {
                'igt_2': OrderIngredientObject(
                    id: 'igt_2',
                    name: 'igt_2-name',
                    amount: 5,
                    additionalCost: 5,
                    additionalPrice: 10,
                    quantityId: 'qty_1',
                    quantityName: 'qty_1-name')
              }),
        ]);
    final map = object.toMap();
    final newObject = OrderObject.build({'id': 1, ...map});
    final newMap = newObject.toMap();

    expect(map, equals(newMap));
  });

  setUpAll(() => initialize());
}
