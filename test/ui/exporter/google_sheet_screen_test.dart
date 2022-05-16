import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/ui/exporter/google_sheet_screen.dart';

import '../../mocks/mock_cache.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Google Sheet Screen', () {
    void prepareData() {
      final i1 = Ingredient(id: 'i1', name: 'i1');
      final i2 = Ingredient(id: 'i2', name: 'i2', currentAmount: 10);
      Stock.instance.replaceItems({'i1': i1, 'i2': i2});

      final q1 = Quantity(id: 'q1', name: 'q1');
      Quantities.instance.replaceItems({'q1': q1});

      final pQ1 = ProductQuantity(id: 'pQ1', quantity: q1);
      final pI1 = ProductIngredient(
          id: 'pI1', ingredient: i1, quantities: {'pQ1': pQ1});
      pI1.prepareItem();
      final p1 = Product(id: 'p1', name: 'p1', ingredients: {'pI1': pI1});
      p1.prepareItem();
      final c1 = Catalog(id: 'c1', name: 'c1', products: {'p1': p1});
      c1.prepareItem();
      Menu.instance.replaceItems({'c1': c1});

      final r1 = Replenishment(id: 'r1', name: 'r1', data: {'i1': 1});
      Replenisher.instance.replaceItems({'r1': r1});

      final o1 = CustomerSettingOption(id: 'o1', name: 'o1', modeValue: 1);
      final o2 = CustomerSettingOption(id: 'o2', name: 'o2', isDefault: true);
      final cs1 = CustomerSetting(id: 'cs1', name: 'cs1', options: {
        'o1': o1,
        'o2': o2,
      });
      cs1.prepareItem();
      CustomerSettings.instance.replaceItems({'cs1': cs1});
    }

    group('Exporter', () {
      testWidgets('preview', (tester) async {
        when(cache.get(any)).thenReturn(null);
        Stock.instance.replaceItems({'i1': Ingredient(id: 'i1', name: 'i1')});

        await tester.pumpWidget(const MaterialApp(home: GoogleSheetScreen()));
        await tester.pumpAndSettle();

        Checkbox checkbox(String key) =>
            find.byKey(Key('gs_export.$key.checkbox')).evaluate().single.widget
                as Checkbox;
        bool isChecked(String key) => checkbox(key).value == true;

        // only non-empty will check default
        const sheets = [
          'menu',
          'stock',
          'quantities',
          'replenisher',
          'customer'
        ];
        expect(sheets.where(isChecked).length, equals(1));

        checkbox('menu').onChanged!(true);
        await tester.pumpAndSettle();
        expect(sheets.where(isChecked).length, equals(2));

        prepareData();

        Future<void> checkPreview(String key, Iterable<String> values) async {
          await tester.tap(find.byKey(Key('gs_export.$key.preview')));
          await tester.pumpAndSettle();
          for (var value in values) {
            expect(find.text(value), findsOneWidget);
          }
          await tester.tap(find.byIcon(Icons.arrow_back_ios_sharp));
          await tester.pumpAndSettle();
        }

        await checkPreview('stock', ['i1']);
        await checkPreview('quantities', ['q1']);
        await checkPreview('menu', ['c1', 'p1', '- i1,0\n  + q1,0,0,0']);
        await checkPreview('replenisher', ['r1', '- i1,1']);
        await checkPreview('customer', ['cs1', '- o1,false,1\n- o2,true,']);
      });
    });

    setUp(() {
      Menu();
      Stock();
      Quantities();
      CustomerSettings();
      Replenisher();
    });

    setUpAll(() {
      initializeTranslator();
      initializeCache();
    });
  });
}
