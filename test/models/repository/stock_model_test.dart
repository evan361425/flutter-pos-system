import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/models/stock/ingredient_model.dart';

import '../../mocks/mock_storage.dart' as storage;
import '../../test_helpers/check_notifier.dart';
import 'stock_model_test.mocks.dart';

@GenerateMocks(
    [IngredientModel, OrderObject, OrderProductObject, OrderIngredientObject])
void main() {
  late StockModel stock;

  group('#updatedDate', () {
    IngredientModel createIngredient(DateTime? updatedAt) {
      final ingredient = MockIngredientModel();
      when(ingredient.updatedAt).thenReturn(updatedAt);

      return ingredient;
    }

    test('should get null if no ingredients', () {
      expect(stock.updatedDate, isNull);
    });

    test('should get null if all ingredient have no updatedAt', () {
      final ing1 = createIngredient(null);
      final ing2 = createIngredient(null);
      stock.replaceChilds({'a': ing1, 'b': ing2});

      expect(stock.updatedDate, isNull);
    });

    test('should get latest updatedAt', () {
      final ing1 = createIngredient(DateTime(2021, 6, 2));
      final ing2 = createIngredient(null);
      final ing3 = createIngredient(DateTime(2021, 6, 3));
      final ing4 = createIngredient(null);
      final ing5 = createIngredient(DateTime(2021, 6, 1));
      stock.replaceChilds(
        {'a': ing1, 'b': ing2, 'c': ing3, 'd': ing4, 'e': ing5},
      );

      expect(stock.updatedDate, equals('2021-06-03'));
    });
  });

  group('#applyAmounts', () {
    IngredientModel createIngredient(num amount, Map<String, Object> info) {
      final ingredient = MockIngredientModel();
      when(ingredient.updateInfo(amount)).thenReturn(info);

      return ingredient;
    }

    test('should ignore if amount == 0 or wrong ID', () async {
      final ing1 = createIngredient(1, {'a': 'b'});
      stock.replaceChilds({'a': ing1});

      final isCalled = await checkNotifierCalled(
          stock, () => stock.applyAmounts({'b': 1, 'a': 0}));

      expect(isCalled, isFalse);
      verifyNever(storage.mock.set(any, any));
    });

    test('should update correctly', () async {
      final ing1 = createIngredient(1, {'a': 'b'});
      final ing2 = createIngredient(2, {'c': 'd'});
      final expected = {'a': 'b', 'c': 'd'};
      stock.replaceChilds({'1': ing1, '2': ing2});

      final isCalled = await checkNotifierCalled(
          stock, () => stock.applyAmounts({'1': 1, '2': 2}));

      expect(isCalled, isTrue);
      verify(storage.mock.set(any, argThat(equals(expected))));
    });
  });

  group('#order', () {
    OrderObject createOrder(List<Map<String, num>> data) {
      final products = data.map<OrderProductObject>((e) {
        final product = MockOrderProductObject();
        final ingredients = <String, OrderIngredientObject>{};

        e.entries.forEach((e) {
          final ingredient = MockOrderIngredientObject();
          when(ingredient.amount).thenReturn(e.value);

          ingredients[e.key] = ingredient;
        });
        when(product.ingredients).thenReturn(ingredients);
        when(product.toString()).thenReturn('hi');

        return product;
      });

      return OrderObject(products: products, totalCount: 1, totalPrice: 1);
    }

    IngredientModel createIngredient(num amount, String id) {
      final ingredient = MockIngredientModel();
      when(ingredient.updateInfo(amount)).thenReturn({id: amount});
      when(ingredient.id).thenReturn(id);

      return ingredient;
    }

    test('should get correct result', () async {
      final data = createOrder([
        {'a': 1, 'b': 2},
        {'a': 3},
      ]);
      stock.addChild(createIngredient(-4, 'a'));
      stock.addChild(createIngredient(-2, 'b'));

      await stock.order(data);

      verify(storage.mock.set(any, argThat(equals({'a': -4, 'b': -2}))));
    });

    test('should reverse amount', () async {
      final data = createOrder([
        {'a': 1, 'b': 2},
        {'a': 3},
      ]);
      final oldData = createOrder([
        {'a': 7, 'b': 8},
        {'a': 9},
      ]);
      stock.addChild(createIngredient(12, 'a'));
      stock.addChild(createIngredient(6, 'b'));

      await stock.order(data, oldData: oldData);

      verify(storage.mock.set(any, argThat(equals({'a': 12, 'b': 6}))));
    });
  });

  setUp(() {
    when(storage.mock.get(any)).thenAnswer((e) => Future.value({}));
    stock = StockModel();
  });

  setUpAll(() {
    storage.before();
  });

  tearDownAll(() {
    storage.after();
  });
}
