import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
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
import 'package:possystem/translator.dart';

import '../../test_helpers/translator.dart';

void main() {
  group('Google Sheet Formatter', () {
    group('Menu', () {
      test('format', () {
        const formatter = GoogleSheetFormatter();
        const ingredients = '''
- i1,1
  + q1,1,1,1
  + q2
- i2
  + q1,0
- i3,1
- i4,1
  + q1
  + q3
- i5
  + q1,1,1,1
''';

        final items = formatter.format<Product>(Formattable.menu, [
          ['A', 'pB', 1, 1, '- i0'],
          ['B', 'pA', 1, 1, 'from-format\n +\n-i'],
          ['C', 'pA', 1, 1],
          ['A', 'pA2', 0, 0, ingredients],
          ['A', 'pA3', 0, 0, '- i4,1\n+q3'],
        ]);

        void verifyProd(Product p, List<String> sValues, List<int> iValues) {
          expect(p.catalog.statusName, equals(sValues[0]));
          expect(p.name, equals(sValues[1]));
          expect(p.statusName, equals(sValues[2]));
          if (sValues.length > 5) {
            expect(p.getItemByName('i0')?.statusName, equals('stagedIng'));
          }
          expect(p.length, equals(iValues[0]));
          expect(p.price, equals(iValues[1]));
          expect(p.cost, equals(iValues[2]));
        }

        // should not changed
        verifyProd(
          Menu.instance.getProduct('pA')!,
          ['normal', 'pA', 'normal'],
          [0, 2, 2],
        );
        expect(Menu.instance.getProduct('pA2')!.length, equals(3));

        // product 1
        verifyProd(
          items[0].item!,
          ['normal', 'pB', 'staged', 'i0', 'stagedIng'],
          [1, 1, 1],
        );

        // product 2
        verifyProd(
          items[1].item!,
          ['staged', 'pA', 'updated'],
          [0, 1, 1],
        );

        expect(items[2].hasError, isTrue);

        final p4 = items[3].item!;
        void verifyIng(
          String iName,
          List<int> values,
          String iStatus, [
          String? qName,
          String? qStatus,
        ]) {
          final ing = p4.getItemByName(iName)!;
          expect(ing.statusName, iStatus);
          expect(ing.amount, equals(values[0]));
          if (qName == null) return;
          final qua = ing.getItemByName(qName)!;
          expect(qua.statusName, qStatus);
          expect(qua.amount, equals(values[1]));
          expect(qua.additionalCost, equals(values[2]));
          expect(qua.additionalPrice, equals(values[3]));
        }

        expect(p4.getItemByName('i1')!.id, 'pAi1');
        expect(p4.getItemByName('i1')!.getItemByName('q1')!.id, equals('pAq1'));
        expect(p4.statusName, equals('normal'));
        verifyIng('i1', [1, 1, 1, 1], 'updated', 'q1', 'updated');
        verifyIng('i1', [1, 0, 0, 0], 'updated', 'q2', 'staged');
        verifyIng('i2', [0, 0, 0, 0], 'normal', 'q1', 'staged');
        verifyIng('i3', [1], 'staged');
        verifyIng('i4', [1, 0, 0, 0], 'staged', 'q1', 'normal');
        verifyIng('i4', [1, 0, 0, 0], 'staged', 'q3', 'stagedQua');
        verifyIng('i5', [0, 1, 1, 1], 'normal', 'q1', 'normal');

        // should use staged item, not create new
        final p4i4 = p4.getItemByName('i4');
        final p5i4 = items[4].item?.getItemByName('i4');
        expect(p4i4?.ingredient.id, equals(p5i4?.ingredient.id));
        final p4q3 = p5i4?.getStagedByName('q3');
        final p5q3 = p4i4?.getStagedByName('q3');
        expect(p4q3?.quantity.id, equals(p5q3?.quantity.id));

        // created
        // i1,i2,i5
        expect(Stock.instance.length, equals(3));
        // i0,i3,i4
        expect(Stock.instance.stagedItems.length, equals(3));
        expect(Stock.instance.getStagedByName('i3'), isNotNull);
        // q1
        expect(Quantities.instance.length, equals(1));
        // q2,q3
        expect(Quantities.instance.stagedItems.length, equals(2));
        expect(Quantities.instance.getStagedByName('q2'), isNotNull);
      });

      setUp(() {
        final menu = Menu();
        final stock = Stock();
        final quantities = Quantities();

        final i1 = Ingredient(id: 'i1', name: 'i1');
        final i2 = Ingredient(id: 'i2', name: 'i2');
        final i5 = Ingredient(id: 'i5', name: 'i5');
        final q1 = Quantity(id: 'q1', name: 'q1');
        stock.replaceItems({'i1': i1, 'i2': i2, 'i5': i5});
        quantities.replaceItems({'q1': q1});
        menu.replaceItems({
          'A': Catalog(id: 'A', name: 'A', products: {
            'pA': Product(id: 'pA', name: 'pA', price: 2, cost: 2),
            'pA2': Product(id: 'pA2', name: 'pA2', ingredients: {
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
          }),
        });
        for (var c in menu.items) {
          c.prepareItem();
          for (var p in c.items) {
            p.prepareItem();
          }
        }
      });
    });

    group('Stock', () {
      test('format', () {
        const formatter = GoogleSheetFormatter();

        final items = formatter.format<Ingredient>(Formattable.stock, [
          ['i1', 2, 3],
          ['i1'],
          [],
          ['i2'],
          ['i3'],
        ]);

        expect(Stock.instance.getItem('i1')!.currentAmount, equals(1));

        void verifyItem(int index, String name, int a, int? t, String status) {
          final item = items[index].item!;
          expect(item.name, equals(name));
          expect(item.currentAmount, equals(a));
          expect(item.totalAmount, equals(t));
          expect(item.statusName, equals(status));
        }

        verifyItem(0, 'i1', 2, 3, 'updated');
        verifyItem(3, 'i2', 0, null, 'normal');
        verifyItem(4, 'i3', 0, null, 'staged');

        expect(items[1].hasError, isTrue);
        expect(items[2].hasError, isTrue);
      });

      setUp(() {
        final stock = Stock();

        final i1 = Ingredient(id: 'i1', name: 'i1', currentAmount: 1);
        final i2 = Ingredient(id: 'i2', name: 'i2');
        stock.replaceItems({'i1': i1, 'i2': i2});
      });
    });

    group('Quantities', () {
      test('format', () {
        const formatter = GoogleSheetFormatter();

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
        const formatter = GoogleSheetFormatter();
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
        const formatter = GoogleSheetFormatter();
        const c1Data = '- co1,true\n- co2,,5';

        final items = formatter.format<OrderAttribute>(Formattable.orderAttr, [
          ['c1', S.orderAttributeModeName('changeDiscount'), c1Data],
          ['c1', '', '- co1,20'],
          ['c2'],
          ['c2', S.orderAttributeModeName('changeDiscount'), '- a,b,10000'],
          ['c2', ''],
          ['c3', S.orderAttributeModeName('changePrice'), '+'],
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
          expect(item.items.length, equals(l));
          expect(item.statusName, equals(status));
        }

        verifyItem(0, 'c1', 'changeDiscount', 2, 'updated');
        expect(items[0].item!.getItem('co1'), isNotNull);
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
