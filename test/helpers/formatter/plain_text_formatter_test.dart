import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/formatter/plain_text_formatter.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';

import '../../test_helpers/translator.dart';

void main() {
  group('Plain Text Formatter', () {
    List<FormattedItem<T>> format<T extends Model>(
      Formattable able,
      String expected,
    ) {
      const formatter = PlainTextFormatter();
      final text = formatter.getRows(able).map((row) => row.join('\n')).join('\n\n');
      expect(text, equals(expected));

      final lines = text.trim().split('\n');

      final guessed = formatter.whichFormattable(lines.removeAt(0));
      return formatter.format<T>(guessed!, [lines]);
    }

    test('menu', () {
      final menu = Menu();
      final stock = Stock();
      final quantities = Quantities();

      final i1 = Ingredient(id: 'i1', name: 'i1');
      final i2 = Ingredient(id: 'i2', name: 'i2');
      final i5 = Ingredient(id: 'i5', name: 'i5');
      final q1 = Quantity(id: 'q1', name: 'q1');
      final q2 = Quantity(id: 'q2', name: 'q2');
      stock.replaceItems({'i1': i1, 'i2': i2, 'i5': i5});
      quantities.replaceItems({'q1': q1, 'q2': q2});
      menu.replaceItems({
        'A': Catalog(id: 'A', name: 'A', products: {
          'pA': Product(id: 'pA', name: 'pA', index: 1, price: 2, cost: 2),
          'pA2': Product(id: 'pA2', name: 'pA2', index: 2, ingredients: {
            'pAi1': ProductIngredient(
              id: 'pAi1',
              amount: 2,
              ingredient: i1,
              quantities: {
                'pAq1': ProductQuantity(
                  id: 'pAq1',
                  amount: 2,
                  additionalCost: 2,
                  additionalPrice: 2,
                  quantity: q1,
                ),
                'pAq2': ProductQuantity(
                  id: 'pAq2',
                  amount: 5,
                  additionalCost: -5,
                  additionalPrice: -5,
                  quantity: q2,
                ),
              },
            ),
            'pAi2': ProductIngredient(id: 'pAi2', ingredient: i2),
            'pAi3': ProductIngredient(
              id: 'pAi3',
              ingredient: i5,
              quantities: {
                'pAq2': ProductQuantity(
                  id: 'pAq2',
                  amount: 1,
                  additionalCost: 1,
                  additionalPrice: 1,
                  quantity: q1,
                ),
              },
            ),
          }),
          'pA3': Product(id: 'pA3', name: 'pA3', index: 3),
        }),
        'B': Catalog(id: 'B', name: 'B'),
        'C': Catalog(id: 'C', name: 'C', products: {
          'pA4': Product(id: 'pA4', name: 'pA4', index: 4),
        }),
      });
      for (var c in menu.items) {
        c.prepareItem();
        for (var p in c.items) {
          p.prepareItem();
        }
      }

      final items = format<Product>(
        Formattable.menu,
        'This menu has 3 categories, 4 products.\n'
        '\n'
        'Category 1 is called A and it has 3 products.\n'
        'Product 1 is called pA, with price at \$2, cost \$2 and it has no ingredient.\n'
        'Product 2 is called pA2, with price at \$0, cost \$0 and it has 3 ingredients: i1、i2、i5.\n'
        'Each product requires 2 of i1 and it also has 2 different quantities ：'
        'q1（quantity 2 with additional price \$2 and cost \$2）、'
        'q2（quantity 5 with additional price \$-5 and cost \$-5）；'
        '0 of i2 and it is unable to adjust quantity；'
        '0 of i5 and it also has one different quantity ：'
        'q1（quantity 1 with additional price \$1 and cost \$1）.\n'
        'Product 3 is called pA3, with price at \$0, cost \$0 and it has no ingredient.\n'
        '\n'
        'Category 2 is called B and it has no product.\n'
        '\n'
        'Category 3 is called C and it has one product.\n'
        'Product 1 is called pA4, with price at \$0, cost \$0 and it has no ingredient.',
      );

      expect(
        items.map((e) {
          final map = e.item?.toObject().toMap();
          map?.remove('createdAt');
          return map.toString();
        }).toList(),
        equals(menu.products.map((e) {
          final map = e.toObject().toMap();
          map.remove('createdAt');
          return map.toString();
        }).toList()),
      );
    });

    test('stock', () {
      final stock = Stock();
      stock.replaceItems({
        'i1': Ingredient(id: 'i1', name: 'i1'),
        'i2': Ingredient(id: 'i2', name: 'i2', currentAmount: 1.0),
        'i3': Ingredient(id: 'i3', name: 'i3', currentAmount: 1.0, totalAmount: 2.0),
        'i4': Ingredient(
          id: 'i4',
          name: 'i4',
          currentAmount: 1.0,
          restockPrice: 2.0,
          restockQuantity: 3.0,
        ),
      });

      final items = format<Ingredient>(
        Formattable.stock,
        'The inventory has 4 ingredients in total.\n'
        '\n'
        'Ingredient at 1 is called i1, with 0 amount.\n'
        'Ingredient at 2 is called i2, with 1 amount.\n'
        'Ingredient at 3 is called i3, with 1 amount, with a maximum of 2 pieces.\n'
        'Ingredient at 4 is called i4, with 1 amount and 3 units of it cost \$2 to replenish.',
      );

      expect(
        items.map((e) => e.item?.toObject().toMap()).toList(),
        equals(stock.items.map((e) => e.toObject().toMap()).toList()),
      );
    });

    test('quantities', () {
      final quantities = Quantities();
      quantities.replaceItems({
        'q1': Quantity(id: 'q1', name: 'q1'),
        'q2': Quantity(id: 'q2', name: 'q2', defaultProportion: 2),
        'q3': Quantity(id: 'q3', name: 'q3', defaultProportion: 0),
        'q4': Quantity(id: 'q4', name: 'q4', defaultProportion: 0.5),
      });

      final items = format<Quantity>(
        Formattable.quantities,
        '4 quantities have been set.\n'
        '\n'
        'Quantity at 1 is called q1, which defaults to multiplying ingredient quantity by 1.\n'
        'Quantity at 2 is called q2, which defaults to multiplying ingredient quantity by 2.\n'
        'Quantity at 3 is called q3, which defaults to multiplying ingredient quantity by 0.\n'
        'Quantity at 4 is called q4, which defaults to multiplying ingredient quantity by 0.5.',
      );

      expect(
        items.map((e) => e.item?.toObject().toMap().toString()).toList(),
        equals(quantities.items.map((e) {
          return e.toObject().toMap().toString();
        }).toList()),
      );
    });

    test('replenisher', () {
      final stock = Stock();
      stock.replaceItems({
        'i1': Ingredient(id: 'i1', name: 'i1'),
        'i2': Ingredient(id: 'i2', name: 'i2'),
        'i3': Ingredient(id: 'i3', name: 'i3'),
      });

      final replenisher = Replenisher();
      replenisher.replaceItems({
        'r1': Replenishment(id: 'r1', name: 'r1'),
        'r2': Replenishment(id: 'r2', name: 'r2', data: {
          'i1': 20,
          'i2': -30,
          'i3': 0.5,
        }),
      });

      final items = format<Replenishment>(
        Formattable.replenisher,
        '2 replenishment methods have been set.\n'
        '\n'
        'Replenishment method at 1 is called r1, it will not adjust inventory.\n'
        'Replenishment method at 2 is called r2, it will adjust the inventory of 3 ingredients：i1（20）、i2（-30）、i3（0.5）.',
      );

      expect(
        items.map((e) => e.item?.toObject().toMap().toString()).toList(),
        equals(replenisher.items.map((e) {
          return e.toObject().toMap().toString();
        }).toList()),
      );
    });

    test('order attributes', () {
      final attrs = OrderAttributes();
      attrs.replaceItems({
        'c1': OrderAttribute(
          id: 'c1',
          name: 'c1',
          index: 1,
          mode: OrderAttributeMode.changePrice,
          options: {
            'o1': OrderAttributeOption(id: 'o1', name: 'o1', index: 1),
            'o2': OrderAttributeOption(
              id: 'o2',
              name: 'o2',
              index: 2,
              isDefault: true,
            ),
            'o3': OrderAttributeOption(
              id: 'o3',
              name: 'o3',
              index: 3,
              modeValue: 20,
            ),
          },
        ),
        'c2': OrderAttribute(id: 'c2', name: 'c2', index: 2),
        'c3': OrderAttribute(
          id: 'c3',
          name: 'c3',
          index: 3,
          mode: OrderAttributeMode.changeDiscount,
          options: {
            'o1': OrderAttributeOption(
              id: 'o1',
              name: 'o1',
              isDefault: true,
              modeValue: 20,
              index: 1,
            ),
            'o2': OrderAttributeOption(
              id: 'o2',
              name: 'o2',
              modeValue: 0,
              index: 2,
            ),
          },
        ),
      });
      for (var attr in attrs.items) {
        attr.prepareItem();
      }

      final items = format<OrderAttribute>(
        Formattable.orderAttr,
        '3 customer attributes have been set.\n'
        '\n'
        'Attribute at 1 is called c1, belongs to Price Change type, it has 3 options：o1、o2（default）、o3（option value is 20）.\n'
        'Attribute at 2 is called c2, belongs to Normal type, it has no options.\n'
        'Attribute at 3 is called c3, belongs to Discount type, it has 2 options：o1（default，option value is 20）、o2（option value is 0）.',
      );

      expect(
        items.map((e) => e.item?.toObject().toMap().toString()).toList(),
        equals(attrs.items.map((e) => '${e.toObject().toMap()}').toList()),
      );
    });

    test('unable to found which formattable', () {
      const formatter = PlainTextFormatter();
      expect(formatter.whichFormattable('some-text'), equals(null));
    });

    setUpAll(() {
      initializeTranslator();
    });
  });
}
