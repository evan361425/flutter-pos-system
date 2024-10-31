import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/order/cart_product.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/stock/ingredient.dart';

import '../mocks/mock_bluetooth.mocks.dart';

void main() {
  group('Model', () {
    group('Menu', () {
      test('Should not implement buildItem', () {
        final catalog = Catalog();
        final product = Product();
        final ingredient = ProductIngredient();

        expect(() => catalog.buildItem('id', {}), throwsUnimplementedError);
        expect(() => product.buildItem('id', {}), throwsUnimplementedError);
        expect(() => ingredient.buildItem('id', {}), throwsUnimplementedError);
      });
    });

    group('Stock', () {
      test('only change current amount will not change update time', () {
        final obj = IngredientObject(currentAmount: 15);
        final ing = Ingredient(id: '1', name: '1', currentAmount: 10);

        final diff = obj.diff(ing);

        expect(diff, equals({'1.currentAmount': 15}));
      });
    });

    group('Order Attribute', () {
      test('Should not implement buildItem', () {
        final attr = OrderAttribute();

        expect(() => attr.buildItem('id', {}), throwsUnimplementedError);
      });

      test('Option calculatePrice', () {
        final s1 = OrderAttribute(options: {
          'so-1': OrderAttributeOption(modeValue: 1),
        })
          ..prepareItem();
        final s2 = OrderAttribute(mode: OrderAttributeMode.changeDiscount, options: {
          'so-2': OrderAttributeOption(modeValue: 50),
        })
          ..prepareItem();
        final s3 = OrderAttribute(mode: OrderAttributeMode.changePrice, options: {
          'so-2': OrderAttributeOption(modeValue: 5),
        })
          ..prepareItem();
        num price = 100;

        for (var option in s1.items) {
          price = option.calculatePrice(price);
        }
        for (var option in s2.items) {
          price = option.calculatePrice(price);
        }
        for (var option in s3.items) {
          price = option.calculatePrice(price);
        }

        expect(price, equals(100 * 0.5 + 5));
      });
    });
  });

  group('Order', () {
    test('Product rebind', () {
      final product = Product(id: 'p-1', name: 'p-1', ingredients: {
        'pi-1': ProductIngredient(id: 'pi-1'),
        'pi-2': ProductIngredient(id: 'pi-2'),
      });
      final order = CartProduct(product, quantities: {
        'pi-1': 'pq-1',
      });

      expect(order.quantities.isEmpty, isTrue);
      expect(order.getQuantityId('pi-1'), equals('pq-1'));

      order.rebind();

      expect(order.quantities.isEmpty, isTrue);
      expect(order.getQuantityId('pi-1'), isNull);
    });
  });

  group('Printer', () {
    test('Order compare', () {
      final p1 = Printer(name: 'p1', autoConnect: true)..p = MockPrinter();
      final p2 = Printer(name: 'p2', autoConnect: true)..p = MockPrinter();
      final p3 = Printer(name: 'p3', autoConnect: false)..p = MockPrinter();
      final p4 = Printer(name: 'p4', autoConnect: false)..p = MockPrinter();

      when(p1.p.connected).thenReturn(true);
      when(p2.p.connected).thenReturn(false);
      when(p3.p.connected).thenReturn(true);
      when(p4.p.connected).thenReturn(false);

      final result = [p1, p2, p3, p4]..sort();
      expect(result.map((e) => e.name).toList(), equals(['p1', 'p3', 'p2', 'p4']));
    });
  });
}
