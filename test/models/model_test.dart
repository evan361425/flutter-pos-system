import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/models/order/order_product.dart';

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

    group('Customer Setting', () {
      test('Option calculatePrice', () {
        final s1 = CustomerSetting(options: {
          'so-1': CustomerSettingOption(modeValue: 1),
        })
          ..prepareItem();
        final s2 = CustomerSetting(
            mode: CustomerSettingOptionMode.changeDiscount,
            options: {
              'so-2': CustomerSettingOption(modeValue: 50),
            })
          ..prepareItem();
        final s3 = CustomerSetting(
            mode: CustomerSettingOptionMode.changePrice,
            options: {
              'so-2': CustomerSettingOption(modeValue: 5),
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
