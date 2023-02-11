import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/objects/stock_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/stock/ingredient.dart';

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
        final s2 =
            OrderAttribute(mode: OrderAttributeMode.changeDiscount, options: {
          'so-2': OrderAttributeOption(modeValue: 50),
        })
              ..prepareItem();
        final s3 =
            OrderAttribute(mode: OrderAttributeMode.changePrice, options: {
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
      final order = OrderProduct(product, selectedQuantity: {
        'pi-1': 'pq-1',
        'pi-3': null,
      });

      order.rebind();

      expect(
        order.selectedQuantity,
        equals({'pi-1': null, 'pi-2': null}),
      );
    });
  });
}
