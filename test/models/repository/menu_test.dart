import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/menu.dart';

import '../../mocks/mock_models.mocks.dart';
import '../../mocks/mock_storage.dart';
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
    test('#hasName', () {
      createCatalog('ctg_1', {'pdt_1': {}, 'pdt_2': {}});
      createCatalog('ctg_2', {});

      expect(menu.hasName('ctg_1-name'), isTrue);
      expect(menu.hasName('ctg_2'), isFalse);
      expect(menu.hasName('ctg_3-name'), isFalse);
    });
  });

  group('#searchProducts', () {
    test('without search text', () {
      final cat1 = createCatalog('ctg_1', {'pdt_1': {}, 'pdt_2': {}});
      final cat2 = createCatalog('ctg_2', {'pdt_3': {}, 'pdt_4': {}});
      final searched = [
        null,
        null,
        DateTime(2020, 1, 25),
        DateTime(2020, 1, 23),
      ].iterator;
      [cat1.items, cat2.items].expand((e) => e).forEach((product) {
        searched.moveNext();
        when(product.searchedAt).thenReturn(searched.current);
      });
      when(cat1.index).thenReturn(1);
      when(cat1.itemList).thenReturn(cat1.items.toList());
      when(cat2.index).thenReturn(2);
      when(cat2.itemList).thenReturn(cat2.items.toList());

      final list1 = menu.searchProducts().toList();
      expect(list1.length, equals(4));
      // searched product first, then index smallest first
      expect(
        list1.map((e) => e.id),
        equals(['pdt_3', 'pdt_4', 'pdt_1', 'pdt_2']),
      );

      final list2 = menu.searchProducts(limit: 2, text: '').toList();
      expect(list2.length, equals(2));
      expect(list2.map((e) => e.id), equals(['pdt_3', 'pdt_4']));
    });

    test('with search text', () {
      final cat1 = createCatalog('ctg_1', {'pdt_1': {}, 'pdt_2': {}});
      final cat2 = createCatalog('ctg_2', {'pdt_3': {}, 'pdt_4': {}});
      var score = 0.0;
      when(cat1.getItemsSimilarity('text'))
          .thenReturn(cat1.items.map((e) => MapEntry(e, score++)));
      when(cat2.getItemsSimilarity('text'))
          .thenReturn(cat2.items.map((e) => MapEntry(e, score++)));

      // zero will be ignore
      final list1 = menu.searchProducts(text: 'text').toList();
      expect(list1.length, equals(3));
      expect(list1.map((e) => e.id), equals(['pdt_4', 'pdt_3', 'pdt_2']));

      final list2 = menu.searchProducts(text: 'text', limit: 2).toList();
      expect(list2.length, equals(2));
      expect(list2.map((e) => e.id), equals(['pdt_4', 'pdt_3']));
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

  setUp(() {
    when(storage.get(any)).thenAnswer((e) => Future.value({}));
    menu = Menu();
  });

  setUpAll(() {
    initializeStorage();
  });
}
