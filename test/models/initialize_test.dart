import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/services/storage.dart';

import '../mocks/mock_database.dart';
import '../mocks/mock_storage.dart';

void main() {
  group('Model Initializing', () {
    test('Failed to access data should not throw error', () async {
      when(storage.get(any, any)).thenAnswer((_) => Future.error('error'));

      await Menu().initialize();

      expect(Menu.instance.isEmpty, isTrue);
    });

    test('Menu', () async {
      Stock().replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1'),
        'i-2': Ingredient(id: 'i-2', name: 'i-2'),
      });
      Quantities().replaceItems({
        'q-1': Quantity(id: 'q-1', name: 'q-1'),
        'q-2': Quantity(id: 'q-2', name: 'q-2'),
      });

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      when(storage.get(Stores.menu, argThat(isNull))).thenAnswer(
        (_) => Future.value({
          'c-1': {
            'index': 1,
            'name': 'c-1',
            'createdAt': now,
            'products': {
              'p-1': {
                'price': 10,
                'cost': 5,
                'index': 1,
                'name': 'p-1',
                'createdAt': now,
                'ingredients': {
                  'pi-1': {
                    'ingredientId': 'i-1',
                    'amount': 5,
                    'quantities': {
                      'pq-1': {
                        'quantityId': 'q-1',
                        'amount': 5,
                        'additionalCost': 5,
                        'additionalPrice': 10,
                      },
                      'q-2': {
                        'amount': -5,
                        'additionalCost': 0,
                        'additionalPrice': 0,
                      },
                      'pq-3': {
                        'quantityId': 'q-3',
                        'amount': 5,
                        'additionalCost': 5,
                        'additionalPrice': 10,
                      },
                    },
                  },
                  'i-2': {'amount': 5},
                  'pi-3': {'ingredientId': 'i-3', 'amount': 5},
                },
              },
              'p-2': {
                'price': 7,
                'cost': 3,
                'index': 2,
                'name': 'p-2',
                'createdAt': now,
                'searchedAt': now,
              }
            },
          },
          'c-2': {
            'index': 2,
            'name': 'c-2',
            'createdAt': now,
          },
          'c-3': {},
        }),
      );

      await Menu().initialize();

      // catalog
      final c1 = Menu.instance.getItem('c-1')!;
      final c2 = Menu.instance.getItem('c-2')!;
      expect(c1.id, equals('c-1'));
      expect(c2.id, equals('c-2'));
      expect(c2.isEmpty, isTrue);
      expect(Menu.instance.getItem('c-3'), isNull);
      // product
      final p1 = c1.itemList.first;
      final p2 = c1.itemList.last;
      expect(p1.id, equals('p-1'));
      expect(p1.catalog, isNotNull);
      expect(p2.id, equals('p-2'));
      expect(p2.catalog, isNotNull);
      expect(p2.isEmpty, isTrue);
      // ingredient
      final pi1 = p1.itemList.first;
      final pi2 = p1.itemList.last;
      expect(pi1.id, equals('pi-1'));
      expect(pi1.ingredient.id, equals('i-1'));
      expect(pi1.name, equals('i-1'));
      expect(pi1.product, isNotNull);
      expect(pi2.id, isNot(equals('i-2')));
      expect(pi2.ingredient.id, equals('i-2'));
      expect(pi2.name, equals('i-2'));
      expect(pi2.product, isNotNull);
      expect(pi2.isEmpty, isTrue);
      // quantity
      final pq1 = pi1.itemList.first;
      final pq2 = pi1.itemList.last;
      expect(pq1.id, equals('pq-1'));
      expect(pq1.quantity.id, equals('q-1'));
      expect(pq1.name, equals('q-1'));
      expect(pq1.amount, equals(5));
      expect(pq1.ingredient, isNotNull);
      expect(pq2.id, isNot(equals('q-2')));
      expect(pq2.quantity.id, equals('q-2'));
      expect(pq2.name, equals('q-2'));
      expect(pq2.amount, equals(-5));
      expect(pq2.ingredient, isNotNull);

      // verify version changed
      verify(storage.setAll(
        Stores.menu,
        argThat(equals({
          'c-1': {
            'index': 1,
            'name': 'c-1',
            'createdAt': now,
            'products': {
              'p-1': {
                'price': 10,
                'cost': 5,
                'index': 1,
                'name': 'p-1',
                'createdAt': now,
                'ingredients': {
                  'pi-1': {
                    'ingredientId': 'i-1',
                    'amount': 5,
                    'quantities': {
                      'pq-1': {
                        'quantityId': 'q-1',
                        'amount': 5,
                        'additionalCost': 5,
                        'additionalPrice': 10
                      },
                      '${pq2.id}': {
                        'quantityId': 'q-2',
                        'amount': -5,
                        'additionalCost': 0,
                        'additionalPrice': 0
                      }
                    }
                  },
                  '${pi2.id}': {
                    'ingredientId': 'i-2',
                    'amount': 5,
                    'quantities': {}
                  }
                }
              },
              'p-2': {
                'price': 7,
                'cost': 3,
                'index': 2,
                'name': 'p-2',
                'createdAt': now,
                'ingredients': {}
              }
            }
          },
          'c-2': {'index': 2, 'name': 'c-2', 'createdAt': now, 'products': {}}
        })),
      ));
    });

    test('Stock', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      when(storage.get(Stores.stock, argThat(isNull))).thenAnswer(
        (_) => Future.value({
          'i-1': {
            'name': 'i-1',
            'currentAmount': 10,
            'warningAmount': 20,
            'alertAmount': 30,
            'lastAmount': 40,
            'lastAddAmount': 30,
            'updatedAt': now,
          },
          'i-2': {'name': 'i-2'},
        }),
      );

      await Stock().initialize();

      final i1 = Stock.instance.getItem('i-1')!;
      final i2 = Stock.instance.getItem('i-2')!;
      expect(i1.name, equals('i-1'));
      expect(i1.currentAmount, equals(10));
      expect(i1.updatedAt, isNotNull);
      expect(i2.name, equals('i-2'));
      expect(i2.currentAmount, isNull);
      expect(i2.updatedAt, isNull);
    });

    test('Quantities', () async {
      when(storage.get(Stores.quantities, argThat(isNull))).thenAnswer(
        (_) => Future.value({
          'q-1': {
            'name': 'q-1',
            'defaultProportion': 10,
          },
          'q-2': {
            'name': 'q-2',
            'defaultProportion': 0,
          },
        }),
      );

      await Quantities().initialize();

      final q1 = Quantities.instance.getItem('q-1')!;
      final q2 = Quantities.instance.getItem('q-2')!;
      expect(q1.name, equals('q-1'));
      expect(q1.defaultProportion, equals(10));
      expect(q2.name, equals('q-2'));
      expect(q2.defaultProportion, isZero);
    });

    test('Replenisher', () async {
      when(storage.get(Stores.replenisher, argThat(isNull))).thenAnswer(
        (_) => Future.value({
          'r-1': {
            'name': 'r-1',
            'data': {
              'i-1': 10,
              'i-2': 0,
              'i-3': -10,
            },
          },
          'r-2': {'name': 'r-2'},
        }),
      );

      await Replenisher().initialize();

      final r1 = Replenisher.instance.getItem('r-1')!;
      final r2 = Replenisher.instance.getItem('r-2')!;
      expect(r1.name, equals('r-1'));
      expect(r1.data, equals({'i-1': 10, 'i-3': -10}));
      expect(r2.name, equals('r-2'));
      expect(r2.data.length, isZero);
    });

    test('CustomerSettings', () async {
      when(database.query(
        CustomerSettings.TABLE,
        where: argThat(equals('isDelete = 0'), named: 'where'),
      )).thenAnswer(
        (_) => Future.value([
          {
            'id': 1,
            'name': 'c-1',
            'index': 1,
            'mode': 1,
          },
          {
            'id': 2,
            'name': 'c-2',
            'index': 2,
            'mode': 0,
          },
          {
            'id': 3,
            'name': 1,
          },
        ]),
      );
      when(database.query(
        CustomerSettings.OPTION_TABLE,
        where: anyNamed('where'),
        whereArgs: argThat(equals([1]), named: 'whereArgs'),
      )).thenAnswer(
        (_) => Future.value([
          {
            'id': 1,
            'name': 'co-1',
            'index': 1,
            'isDefault': 1,
            'modeValue': 1,
          },
          {
            'id': 2,
            'name': 'co-2',
            'index': 2,
            'isDefault': 0,
            'modeValue': null,
          },
        ]),
      );
      when(database.query(
        CustomerSettings.OPTION_TABLE,
        where: anyNamed('where'),
        whereArgs: argThat(equals([2]), named: 'whereArgs'),
      )).thenAnswer((_) => Future.error('error'));

      await CustomerSettings().initialize();

      final c1 = CustomerSettings.instance.getItem('1')!;
      final c2 = CustomerSettings.instance.getItem('2')!;
      expect(c1.name, equals('c-1'));
      expect(c2.name, equals('c-2'));
      expect(c2.isEmpty, isTrue);
      expect(CustomerSettings.instance.getItem('3'), isNull);
      expect(c1.itemList.first.modeValue, equals(1));
      expect(c1.itemList.last.modeValue, isNull);
    });

    setUpAll(() {
      initializeDatabase();
      initializeStorage();
      LOG_LEVEL = 0;
    });
  });
}
