import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_models.mocks.dart';
import '../../mocks/mock_storage.dart';
import '../../mocks/mock_widgets.dart';
import '../../mocks/mock_repos.dart';
import '../../test_helpers/check_notifier.dart';

void main() {
  test('#constructor', () {
    when(storage.get(any)).thenAnswer((e) => Future.value({
          'id1': {
            'name': 'catalog1',
            'index': 1,
            'createdAt': 1623639573,
            'products': {
              'pid1': {
                'name': 'product1',
                'index': 1,
                'price': 1,
                'cost': 2,
                'createdAt': 1623639573
              },
            },
          },
          'id2': {
            'name': 'catalog2',
            'index': 2,
            'createdAt': 1623639573,
          },
        }));
    final menu = Menu();

    var isCalled = false;
    menu.addListener(() {
      expect(menu.getItem('id1')!.getItem('pid1')!.name, equals('product1'));
      expect(menu.getItem('id2')!.items, isEmpty);
      expect(menu.isReady, isTrue);
      isCalled = true;
    });

    Future.delayed(Duration.zero, () => expect(isCalled, isTrue));
  });

  late Menu menu;

  MockCatalog createCatalog(
      String id, Map<String, Map<String, List<String>>> products) {
    final catalog = MockCatalog();

    when(catalog.id).thenReturn(id);
    when(catalog.name).thenReturn('$id-name');
    final cItems = <MockProduct>[];
    when(catalog.items).thenReturn(cItems);
    when(catalog.getItem(any)).thenReturn(null);

    products.forEach((productId, ingredients) {
      final product = MockProduct();

      when(product.id).thenReturn(productId);
      when(product.name).thenReturn('$productId-name');
      final pItems = <MockProductIngredient>[];
      when(product.items).thenReturn(pItems);
      when(product.getItem(any)).thenReturn(null);

      ingredients.forEach((ingredientId, quantities) {
        final ingredient = MockProductIngredient();
        when(ingredient.id).thenReturn(ingredientId);
        when(ingredient.prefix)
            .thenReturn('$id-$productId-$ingredientId-prefix');
        when(ingredient.product).thenReturn(product);
        when(ingredient.getItem(any)).thenReturn(null);

        final iItems = quantities.map((quantityId) {
          final quantity = MockProductQuantity();
          when(quantity.id).thenReturn(quantityId);
          when(quantity.prefix)
              .thenReturn('$id-$productId-$ingredientId-$quantityId-prefix');
          when(quantity.ingredient).thenReturn(ingredient);
          when(ingredient.getItem(quantityId)).thenReturn(quantity);

          return quantity;
        }).toList();

        when(ingredient.items).thenReturn(iItems);

        when(product.getItem(ingredientId)).thenReturn(ingredient);
        pItems.add(ingredient);
      });

      when(catalog.getItem(productId)).thenReturn(product);
      cItems.add(product);
    });

    menu.addItem(catalog);

    return catalog;
  }

  group('getter', () {
    test('#getProduct', () {
      createCatalog('id1', {'pdt_1': {}, 'pdt_2': {}});
      createCatalog('id2', {'pdt_3': {}, 'pdt_4': {}});

      expect(menu.getProduct('pdt_1'), isNotNull);
      expect(menu.getProduct('pdt_4'), isNotNull);
      expect(menu.getProduct('pdt_5'), isNull);
    });

    test('#getIngredients', () {
      createCatalog('id1', {
        'pdt_1': {'igt_1': [], 'igt_2': []},
        'pdt_2': {'igt_1': [], 'igt_3': []},
      });
      createCatalog('id2', {
        'pdt_3': {'igt_1': [], 'igt_3': []},
        'pdt_4': {'igt_2': [], 'igt_4': []},
      });

      expect(menu.getIngredients('igt_1').length, equals(3));
      expect(menu.getIngredients('igt_2').length, equals(2));
      expect(menu.getIngredients('igt_5'), isEmpty);
    });

    test('#getQuantities', () {
      createCatalog('id1', {
        'pdt_1': {
          'igt_1': ['qty_1', 'qty_2'],
          'igt_2': ['qty_1', 'qty_3'],
        },
        'pdt_2': {
          'igt_1': [],
          'igt_3': ['qty_2', 'qty_4']
        },
      });
      createCatalog('id2', {
        'pdt_3': {
          'igt_1': ['qty_2'],
          'igt_3': ['qty_4']
        },
      });

      expect(menu.getQuantities('qty_1').length, equals(2));
      expect(menu.getQuantities('qty_2').length, equals(3));
      expect(menu.getQuantities('qty_5'), isEmpty);
    });
  });

  group('checker', () {
    test('#hasCatalog', () {
      createCatalog('ctg_1', {'pdt_1': {}, 'pdt_2': {}});
      createCatalog('ctg_2', {});

      expect(menu.hasName('ctg_1-name'), isTrue);
      expect(menu.hasName('ctg_2'), isFalse);
      expect(menu.hasName('ctg_3-name'), isFalse);
    });
  });

  group('remover', () {
    test('should do nothing if not found', () async {
      createCatalog('ctg_1', {
        'pdt_1': {'igt_1': []},
        'pdt_2': {'igt_1': []},
      });

      final isCalled = await checkNotifierCalled(
          menu, () => menu.removeIngredients('igt_2'));

      expect(isCalled, isFalse);
      verifyNever(storage.set(any, any));
    });

    test('should fire storage and notify listener', () async {
      createCatalog('ctg_1', {
        'pdt_1': {'igt_1': []},
        'pdt_2': {'igt_1': []},
      });

      final isCalled = await checkNotifierCalled(
          menu, () => menu.removeIngredients('igt_1'));

      expect(isCalled, isTrue);
      verify(storage.set(
        any,
        argThat(equals({
          'ctg_1-pdt_1-igt_1-prefix': null,
          'ctg_1-pdt_2-igt_1-prefix': null,
        })),
      ));
      final product1 = menu.getProduct('pdt_1') as MockProduct;
      final product2 = menu.getProduct('pdt_2') as MockProduct;
      verify(product1.removeItem(argThat(equals('igt_1'))));
      verify(product2.removeItem(argThat(equals('igt_1'))));
    });

    test('should work on quantity', () async {
      createCatalog('ctg_1', {
        'pdt_1': {
          'igt_1': ['qty_1']
        },
        'pdt_2': {
          'igt_2': ['qty_1']
        },
      });

      final isCalled =
          await checkNotifierCalled(menu, () => menu.removeQuantities('qty_1'));

      expect(isCalled, isTrue);
      verify(storage.set(
        any,
        argThat(equals({
          'ctg_1-pdt_1-igt_1-qty_1-prefix': null,
          'ctg_1-pdt_2-igt_2-qty_1-prefix': null,
        })),
      ));
      final igt1 = menu.getIngredients('igt_1').first as MockProductIngredient;
      final igt2 = menu.getIngredients('igt_2').first as MockProductIngredient;
      verify(igt1.removeItem(argThat(equals('qty_1'))));
      verify(igt2.removeItem(argThat(equals('qty_1'))));
    });
  });

  group('#setUpStockMode', () {
    test('should not do anything if already set', () {
      menu.stockMode = true;
      expect(menu.setUpStockMode(MockBuildContext()), isTrue);
    });

    testWidgets('should return false if stock not ready', (tester) async {
      when(stock.isReady).thenReturn(false);
      when(quantities.isReady).thenReturn(true);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Stock>(create: (_) => stock),
          ChangeNotifierProvider<Quantities>(create: (_) => quantities),
        ],
        builder: (context, _) {
          final result = menu.setUpStockMode(context);
          expect(result, isFalse);
          return Container();
        },
      ));
    });

    testWidgets('should return false if quantities not ready', (tester) async {
      when(stock.isReady).thenReturn(true);
      when(quantities.isReady).thenReturn(false);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Stock>(create: (_) => stock),
          ChangeNotifierProvider<Quantities>(create: (_) => quantities),
        ],
        builder: (context, _) {
          final result = menu.setUpStockMode(context);
          expect(result, isFalse);
          return Container();
        },
      ));
    });

    testWidgets('should set up correctly', (tester) async {
      final catalog1 = createCatalog('id-1', {
        'p-id1': {
          'i-id1': ['q-id1', 'q-id2'],
        },
      });

      when(stock.isReady).thenReturn(true);
      when(quantities.isReady).thenReturn(true);
      when(stock.getItem(any)).thenReturn(MockIngredient());
      when(quantities.getItem(any)).thenReturn(MockQuantity());
      menu.replaceItems({'id-1': catalog1});

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Stock>(create: (_) => stock),
          ChangeNotifierProvider<Quantities>(create: (_) => quantities),
        ],
        builder: (context, _) {
          final result = menu.setUpStockMode(context);
          expect(result, isTrue);
          return Container();
        },
      ));

      catalog1.items.forEach((product) {
        product.items.forEach((ingredient) {
          verify((ingredient as MockProductIngredient).setIngredient(any))
              .called(1);
          ingredient.items.forEach((quantity) {
            verify((quantity as MockProductQuantity).setQuantity(any))
                .called(1);
          });
        });
      });
    });
  });

  setUp(() {
    when(storage.get(any)).thenAnswer((e) => Future.value({}));
    menu = Menu();
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
