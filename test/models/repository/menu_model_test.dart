import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/menu_model.dart';

import '../../mocks/mock_storage.dart' as storage;

void main() {
  test('#constructor', () {
    when(storage.mock.get(any)).thenAnswer((e) => Future.value({
          'id1': {
            'name': 'catalog1',
            'index': 1,
            'products': {
              'pid1': {'name': 'product1', 'index': 1, 'price': 1, 'cost': 2},
            },
          },
          'id2': {
            'name': 'catalog2',
            'index': 2,
          },
        }));
    final menu = MenuModel();

    var isCalled = false;
    menu.addListener(() {
      expect(menu.getItem('id1')!.getItem('pid1')!.name, equals('product1'));
      expect(menu.getItem('id2')!.items, isEmpty);
      expect(menu.isReady, isTrue);
      isCalled = true;
    });

    Future.delayed(Duration.zero, () => expect(isCalled, isTrue));
  });

  late MenuModel menu;

  test('#getIngredients', () {});

  setUp(() {
    when(storage.mock.get(any)).thenAnswer((e) => Future.value({}));
    menu = MenuModel();
  });

  setUpAll(() {
    storage.before();
  });

  tearDownAll(() {
    storage.after();
  });
}
