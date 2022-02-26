import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/debug/random_gen_order.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';

void main() {
  group('Random Generate Order', () {
    test('default setting', () {
      final result = generateOrder(orderCount: 10);

      expect(result.length, equals(10));
      expect(result.map((e) => e.totalCount).reduce((a, b) => a + b),
          greaterThan(10));
    });
  });

  setUpAll(() {
    final stock = Stock()
      ..replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1'),
        'i-2': Ingredient(id: 'i-2', name: 'i-2'),
        'i-3': Ingredient(id: 'i-3', name: 'i-3'),
      });
    final qs = Quantities()
      ..replaceItems({
        'q-1': Quantity(id: 'q-1', name: 'q-1'),
        'q-2': Quantity(id: 'q-2', name: 'q-2'),
        'q-3': Quantity(id: 'q-3', name: 'q-3'),
      });
    final q1 = ProductQuantity(
      id: 'pq-1',
      quantity: qs.getItem('q-1'),
      additionalCost: 1,
      additionalPrice: 1,
      amount: 1,
    );
    final q2 = ProductQuantity(
      id: 'pq-2',
      quantity: qs.getItem('q-2'),
      additionalCost: 3,
      additionalPrice: 3,
      amount: 3,
    );
    final q3 = ProductQuantity(
      id: 'pq-3',
      quantity: qs.getItem('q-3'),
      additionalCost: -5,
      additionalPrice: -5,
      amount: -5,
    );
    final i1 = ProductIngredient(
      id: 'pi-1',
      ingredient: stock.getItem('i-1'),
      amount: 11,
      quantities: {'pq-1': q1, 'p1-2': q2},
    )..prepareItem();
    final i2 = ProductIngredient(
      id: 'pi-2',
      ingredient: stock.getItem('i-2'),
      amount: 13,
      quantities: {'pq-3': q3},
    )..prepareItem();
    final i3 = ProductIngredient(
      id: 'pi-3',
      ingredient: stock.getItem('i-3'),
      amount: 13,
    );
    final p1 = Product(
      id: 'p-1',
      name: 'p-1',
      cost: 17,
      price: 23,
      ingredients: {'pi-1': i1, 'pi-2': i2},
    )..prepareItem();
    final p2 = Product(
      id: 'p-2',
      name: 'p-2',
      cost: 29,
      price: 31,
      ingredients: {'pi-3': i3},
    )..prepareItem();
    final p3 = Product(id: 'p-3', name: 'p-3', cost: 37, price: 41);
    Menu().replaceItems({
      'c-1': Catalog(id: 'c-1', products: {'p-1': p1, 'p-2': p2, 'p-3': p3})
        ..prepareItem()
    });
  });
}
