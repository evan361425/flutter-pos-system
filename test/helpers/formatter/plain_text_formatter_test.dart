import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/formatter/plain_text_formatter.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model.dart';
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
    List<FormattedItem<T>> format<T extends Model>(Formattable able) {
      const formatter = PlainTextFormatter();
      final text =
          formatter.getRows(able).map((row) => row.join('\n')).join('\n\n');
      final lines = text.trim().split('\n');
      lines.removeAt(0);
      return formatter.format<T>(able, [lines]);
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

      final items = format<Product>(Formattable.menu);

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
        'i2': Ingredient(id: 'i2', name: 'i2', currentAmount: 1),
        'i3':
            Ingredient(id: 'i3', name: 'i3', currentAmount: 1, totalAmount: 2),
      });

      final items = format<Ingredient>(Formattable.stock);

      expect(
        items.map((e) => e.item?.toObject().toMap().toString()).toList(),
        equals(
            stock.items.map((e) => e.toObject().toMap().toString()).toList()),
      );
    });

    group('Quantities', () {
      test('format', () {
        const formatter = PlainTextFormatter();

        final items = formatter.format<Quantity>(Formattable.quantities, [
          ['q1', 2],
          ['q1'],
          [],
          ['q2'],
          ['q3'],
        ]);

        // should not changed
        expect(Quantities.instance.getItem('q1')!.defaultProportion, equals(1));

        void verifyItem(int index, String name, int p, String status) {
          final item = items[index].item!;
          expect(item.name, equals(name));
          expect(item.defaultProportion, equals(p));
          expect(item.statusName, equals(status));
        }

        verifyItem(0, 'q1', 2, 'updated');
        verifyItem(3, 'q2', 1, 'normal');
        verifyItem(4, 'q3', 1, 'staged');

        expect(items[1].hasError, isTrue);
        expect(items[2].hasError, isTrue);
      });

      setUp(() {
        final quantities = Quantities();

        final q1 = Quantity(id: 'q1', name: 'q1');
        final q2 = Quantity(id: 'q2', name: 'q2');
        quantities.replaceItems({'q1': q1, 'q2': q2});
      });
    });

    group('Replenisher', () {
      test('format', () {
        const formatter = PlainTextFormatter();
        const r1Data = '- i1,20\n- i2,-5';

        final items = formatter.format<Replenishment>(Formattable.replenisher, [
          ['r1', r1Data],
          ['r1'],
          [],
          ['r2', '- ,'],
          ['r2'],
          ['r3', '- i1,\n+\n- i3'],
        ]);

        // should not changed
        expect(Replenisher.instance.getItem('r1')!.data.isEmpty, isTrue);

        void verifyItem(int index, String name, int l, String status) {
          final item = items[index].item!;
          expect(item.name, equals(name));
          expect(item.data.length, equals(l));
          expect(item.statusName, equals(status));
        }

        verifyItem(0, 'r1', 2, 'updated');
        expect(items[1].hasError, isTrue);
        expect(items[2].hasError, isTrue);
        expect(items[3].hasError, isTrue);
        verifyItem(4, 'r2', 0, 'normal');
        verifyItem(5, 'r3', 0, 'staged');

        final i2 = Stock.instance.getStagedByName('i2');
        expect(items[0].item!.data, equals({'i1': 20, i2!.id: -5}));
      });

      setUp(() {
        final stock = Stock();
        final replenisher = Replenisher();

        final r1 = Replenishment(id: 'r1', name: 'r1');
        final r2 = Replenishment(id: 'r2', name: 'r2');
        replenisher.replaceItems({'r1': r1, 'r2': r2});

        stock.replaceItems({'i1': Ingredient(id: 'i1', name: 'i1')});
      });
    });

    group('OrderAttributes', () {
      test('format', () {
        const formatter = PlainTextFormatter();
        const c1Data = '- co1,true\n- co2,,5';

        final items = formatter.format<OrderAttribute>(Formattable.orderAttr, [
          ['c1', '折扣', c1Data],
          ['c1', '', '- co1,20'],
          ['c2'],
          ['c2', '折扣', '- a,b,10000'],
          ['c2', ''],
          ['c3', '變價', '+'],
        ]);

        // should not changed
        expect(OrderAttributes.instance.getItem('c1')!.length, equals(1));

        void verifyItem(
          int index,
          String name,
          String mode,
          int l,
          String status,
        ) {
          final item = items[index].item!;
          expect(item.name, equals(name));
          expect(item.mode.name, equals(mode));
          expect(item.stagedItems.length, equals(l));
          expect(item.statusName, equals(status));
        }

        verifyItem(0, 'c1', 'changeDiscount', 2, 'updated');
        expect(items[0].item!.getStaged('co1'), isNotNull);
        expect(items[1].hasError, isTrue);
        expect(items[2].hasError, isTrue);
        expect(items[3].hasError, isTrue);
        verifyItem(4, 'c2', 'statOnly', 0, 'normal');
        verifyItem(5, 'c3', 'changePrice', 0, 'staged');
      });

      setUp(() {
        final attrs = OrderAttributes();

        final c1 = OrderAttribute(id: 'c1', name: 'c1', options: {
          'co1': OrderAttributeOption(id: 'co1', name: 'co1'),
        });
        final c2 = OrderAttribute(id: 'c2', name: 'c2');
        attrs.replaceItems({'c1': c1, 'c2': c2});
      });
    });

    setUpAll(() {
      initializeTranslator();
    });
  });
}
