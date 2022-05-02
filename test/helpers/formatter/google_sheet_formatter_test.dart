import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/formatter/google_sheet_formatter.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';

import '../../test_helpers/translator.dart';

void main() {
  group('Formatter Google Sheet', () {
    group('Menu', () {
      test('Format', () {
        const formatter = GoogleSheetFormatter();
        const ingredients = '''
- i1,1
  + q1,1,1,1
  + q2
- i2
  + q1,1
- i3,1
''';
        final target = GoogleSheetFormatter.getTarget(GoogleSheetAble.menu);

        final items = formatter.format<Product>(target, [
          ['A', 'pB', 1, 1],
          ['B', 'pA', 1, 1, 'from-format\n +\n-i'],
          ['C', 'pA', 1, 1],
          ['A', 'pA2', 0, 0, ingredients],
        ]);

        // should not changed
        final pA = Menu.instance.getProduct('pA')!;
        expect(pA.price, equals(2));
        expect(pA.cost, equals(2));
        expect(pA.isEmpty, isTrue);
        expect(Menu.instance.getProduct('pA2')!.length, equals(2));

        // product 1
        final p1 = items[0].item!;
        expect(p1.catalog.status.name, equals('updated'));
        expect(p1.price, equals(1));
        expect(p1.cost, equals(1));
        expect(p1.name, equals('pB'));

        // product 2~3
        final p2 = items[1].item!;
        expect(p2.catalog.status.name, equals('staged'));
        expect(p2.isEmpty, isTrue);
        expect(items[2].hasError, isTrue);

        final p4 = items[3].item!;
        void verifyIng(String iName, List<int> values, [String? qName]) {
          final ing = p4.getItemByName(iName)!;
          expect(ing.amount, equals(values[0]));
          if (qName == null) return;
          final qua = ing.getItemByName(qName)!;
          expect(qua.amount, equals(values[1]));
          expect(qua.additionalCost, equals(values[2]));
          expect(qua.additionalPrice, equals(values[3]));
        }

        expect(p4.getItemByName('i1')!.id, 'pAi1');
        expect(p4.getItemByName('i1')!.getItemByName('q1')!.id, equals('pAq1'));
        verifyIng('i1', [1, 1, 1, 1], 'q1');
        verifyIng('i1', [1, 0, 0, 0], 'q2');
        verifyIng('i2', [0, 1, 0, 0], 'q1');
        verifyIng('i3', [1]);
        // created
        expect(Stock.instance.length, equals(2));
        expect(Stock.instance.getStagedByName('i3'), isNotNull);
        expect(Quantities.instance.length, equals(1));
        expect(Quantities.instance.getStagedByName('q2'), isNotNull);
      });

      setUp(() {
        final menu = Menu();
        final stock = Stock();
        final quantities = Quantities();

        final i1 = Ingredient(id: 'i1', name: 'i1');
        final i2 = Ingredient(id: 'i2', name: 'i2');
        final q1 = Quantity(id: 'q1', name: 'q1');
        stock.replaceItems({'i1': i1, 'i2': i2});
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
            }),
          }),
        });
      });
    });

    setUpAll(() {
      initializeTranslator();
    });
  });
}
