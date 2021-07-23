import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';

import '../../mocks/mockito/mock_order_object.dart';
import '../../mocks/mockito/mock_product_model.dart';
import '../../mocks/mocks.dart';
import '../../mocks/providers.dart';
import '../../test_helpers/check_notifier.dart';
import '../menu/product_ingredient_model_test.mocks.dart';
import '../menu/product_quantity_model_test.mocks.dart';
import '../order/order_product_model_test.mocks.dart';
import 'cart_model_test.mocks.dart';
import 'stock_model_test.mocks.dart';

@GenerateMocks([OrderProductModel])
void main() {
  final cart = CartModel();

  Iterable<MockOrderProductModel> createProducts(
    List<String> ids, {
    isSelected = true,
    count = 0,
    price = 0,
    List<Map<String, MockOrderIngredientModel>> ingredients = const [],
  }) {
    var index = 0;
    final products = ids.map((id) {
      final orderProduct = MockOrderProductModel();
      final product = MockProductModel();
      when(orderProduct.product).thenReturn(product);
      when(orderProduct.isSelected).thenReturn(isSelected);
      when(orderProduct.count).thenReturn(count);
      when(orderProduct.price).thenReturn(price);
      when(product.id).thenReturn(id);
      when(product.price).thenReturn(price);
      if (ingredients.isNotEmpty) {
        when(orderProduct.getIngredient(any)).thenReturn(null);
        ingredients[index].forEach((ingredientId, ingredient) {
          when(orderProduct.getIngredient(ingredientId)).thenReturn(ingredient);
        });
      }

      index++;
      return orderProduct;
    });
    cart.products.addAll(products);

    return products;
  }

  test('#isSameProducts', () {
    createProducts([]);
    expect(cart.isSameProducts, isFalse);

    cart.clear();
    createProducts(['id_1', 'id_2']);
    expect(cart.isSameProducts, isFalse);

    cart.clear();
    createProducts(['id_1', 'id_1']);
    createProducts(['id_2'], isSelected: false);
    expect(cart.isSameProducts, isTrue);
  });

  test('#totalCount', () {
    createProducts(['1', '2'], count: 2);
    createProducts(['1', '2'], count: 3, isSelected: false);

    expect(cart.totalCount, equals(10));
  });

  test('#totalPrice', () {
    createProducts(['1', '2'], price: 2);
    createProducts(['1', '2'], price: 3, isSelected: false);

    expect(cart.totalPrice, equals(10));
  });

  test('#add', () {
    final product = MockProductModel();
    when(product.price).thenReturn(1);

    expect(checkNotifierCalled(cart, () => cart.add(product)), isTrue);
    expect(identical(cart.products.first.product, product), isTrue);
  });

  test('#drop', () async {
    final action = () => cart.drop();
    when(orders.drop()).thenAnswer((_) => Future.value(null));
    expect(await checkNotifierCalled(cart, action, isFalse), isFalse);

    LOG_LEVEL = 2;
    final order = MockOrderObject();
    final product = MockOrderProductModel();
    when(order.id).thenReturn(1);
    when(order.parseToProduct()).thenReturn([product]);
    when(orders.drop()).thenAnswer((_) => Future.value(order));

    expect(await checkNotifierCalled(cart, action, isTrue), isTrue);
    expect(identical(cart.products.first, product), isTrue);
  });

  group('#getSelectedQuantityId', () {
    test('should return null if not all products is same', () {
      final ingredient = MockProductIngredientModel();
      createProducts(['id_1', 'id_2']);
      expect(cart.getSelectedQuantityId(ingredient), isNull);
    });

    test('should return null if quantities are different', () {
      final ingredient = MockProductIngredientModel();
      final orderIgt1 = MockOrderIngredientModel();
      final orderIgt2 = MockOrderIngredientModel();
      final quantity1 = MockProductQuantityModel();
      final quantity2 = MockProductQuantityModel();
      when(ingredient.id).thenReturn('igt_1');
      when(orderIgt1.quantity).thenReturn(quantity1);
      when(orderIgt2.quantity).thenReturn(quantity2);
      when(quantity1.id).thenReturn('qty_1');
      when(quantity2.id).thenReturn('qty_2');
      createProducts([
        'id_1',
        'id_1',
      ], ingredients: [
        {'igt_1': orderIgt1},
        {'igt_1': orderIgt2},
      ]);

      expect(cart.getSelectedQuantityId(ingredient), isNull);
    });

    test('should return DEFAULT_QUANTITY_ID if quantities are all null', () {
      final ingredient = MockProductIngredientModel();
      when(ingredient.id).thenReturn('igt_1');
      createProducts(['id_1', 'id_1'], ingredients: [{}, {}]);

      expect(
        cart.getSelectedQuantityId(ingredient),
        CartModel.DEFAULT_QUANTITY_ID,
      );
    });

    test('should return same quantity ID', () {
      final ingredient = MockProductIngredientModel();
      final orderIgt1 = MockOrderIngredientModel();
      final orderIgt2 = MockOrderIngredientModel();
      final quantity1 = MockProductQuantityModel();
      final quantity2 = MockProductQuantityModel();
      when(ingredient.id).thenReturn('igt_1');
      when(orderIgt1.quantity).thenReturn(quantity1);
      when(orderIgt2.quantity).thenReturn(quantity2);
      when(quantity1.id).thenReturn('qty_1');
      when(quantity2.id).thenReturn('qty_1');
      createProducts([
        'id_1',
        'id_1',
      ], ingredients: [
        {'igt_1': orderIgt1},
        {'igt_1': orderIgt2},
      ]);

      expect(cart.getSelectedQuantityId(ingredient), equals('qty_1'));
    });
  });

  group('#paid', () {
    test('should throw error if paid is not enough', () async {
      createProducts(['id_1', 'id_2'], price: 2, count: 2);
      expect(() => cart.paid(3), throwsA(equals('too low')));
    });

    test('should add order successfully', () async {
      LOG_LEVEL = 2;
      createProducts(['id_1', 'id_2'], price: 2, count: 2).forEach((e) {
        when(e.toObject()).thenReturn(MockOrderProductObject());
      });

      final isCalled = await checkNotifierCalled(cart, () => cart.paid(null));

      expect(isCalled, isTrue);
      expect(cart.isEmpty, isTrue);
      verify(stock.order(any));
    });

    test('should add order in history mode', () async {
      LOG_LEVEL = 2;
      cart.isHistoryMode = true;
      createProducts(['id_1', 'id_2'], price: 2, count: 2).forEach((e) {
        when(e.toObject()).thenReturn(MockOrderProductObject());
      });
      final object = MockOrderObject();
      when(orders.pop()).thenAnswer((_) => Future.value(object));
      when(object.id).thenReturn(1);
      when(object.createdAt).thenReturn(DateTime.now());
      when(object.totalPrice).thenReturn(100);

      final isCalled = await checkNotifierCalled(cart, () => cart.paid(5));

      expect(isCalled, isTrue);
      expect(cart.isEmpty, isTrue);
      expect(cart.isHistoryMode, isFalse);
      verify(stock.order(any, oldData: object));
    });
  });

  group('#popHistory', () {
    test('should return false if pop null', () async {
      when(orders.pop()).thenAnswer((_) => Future.value(null));
      final isCalled =
          await checkNotifierCalled(cart, () => cart.popHistory(), isFalse);

      expect(isCalled, isFalse);
    });

    test('should return true', () async {
      LOG_LEVEL = 2;
      final order = MockOrderObject();
      final product = MockOrderProductModel();
      when(orders.pop()).thenAnswer((_) => Future.value(order));
      when(order.id).thenReturn(1);
      when(order.parseToProduct()).thenReturn([product]);
      final isCalled =
          await checkNotifierCalled(cart, () => cart.popHistory(), isTrue);

      expect(isCalled, isTrue);
      expect(cart.isHistoryMode, isTrue);
      expect(identical(cart.products.first, product), isTrue);
    });
  });

  test('#removeSelected', () async {
    createProducts(['id_1', 'id_2']);
    createProducts(['id_3'], isSelected: false);

    final isCalled =
        await checkNotifierCalled(cart, () => cart.removeSelected());

    expect(isCalled, isTrue);
    expect(cart.products.length, equals(1));
  });

  group('#stash', () {
    test('should return true if empty, since it allow continue actions',
        () async {
      final isCalled =
          await checkNotifierCalled(cart, () => cart.stash(), isTrue);
      expect(isCalled, isFalse);
    });

    test('should return false if over rate limit', () async {
      createProducts(['id_1']);
      when(orders.getStashCount()).thenAnswer((_) => Future.value(5));

      final isCalled =
          await checkNotifierCalled(cart, () => cart.stash(), isFalse);

      expect(isCalled, isFalse);
    });

    test('should success', () async {
      LOG_LEVEL = 2;
      createProducts(['id_1']);
      when(orders.getStashCount()).thenAnswer((_) => Future.value(1));

      final isCalled =
          await checkNotifierCalled(cart, () => cart.stash(), isTrue);

      expect(isCalled, isTrue);
      verify(orders.stash(any));
    });
  });

  test('should not failed in several actions', () {
    when(currency.isInt).thenReturn(true);
    createProducts(['id_1']);
    cart.products.forEach((element) {
      when(element.toggleSelected(any)).thenReturn(false);
    });
    final ingredient = MockOrderIngredientModel();

    cart.removeSelectedIngredient('id');
    cart.toggleAll(true);
    cart.toggleAll(false);
    cart.toggleAll();
    cart.updateSelectedCount(null);
    cart.updateSelectedCount(10);
    cart.updateSelectedDiscount(null);
    cart.updateSelectedDiscount(10);
    cart.updateSelectedIngredient(ingredient);
    cart.updateSelectedPrice(null);
    cart.updateSelectedPrice(10);
  });

  test('#toObject', () {
    createProducts(['id_1'], price: 1, count: 2).forEach((e) {
      when(e.toObject()).thenReturn(MockOrderProductObject());
    });
    final object = cart.toObject(paid: 100);

    expect(object.id, isNull);
    expect(object.createdAt, isNotNull);
    expect(object.paid, equals(100));
    expect(object.totalCount, equals(2));
    expect(object.products.length, equals(1));
  });

  setUp(() {
    cart.replaceProducts([]);
  });

  setUpAll(() {
    initialize();
    initializeProviders();
  });
}
