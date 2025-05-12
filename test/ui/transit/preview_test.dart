import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  void prepareData() {
    final i1 = Ingredient(id: 'i1', name: 'i1');
    final i2 = Ingredient(id: 'i2', name: 'i2', currentAmount: 10);
    Stock.instance.replaceItems({'i1': i1, 'i2': i2});

    final q1 = Quantity(id: 'q1', name: 'q1');
    Quantities.instance.replaceItems({'q1': q1});

    final pQ1 = ProductQuantity(id: 'pQ1', quantity: q1);
    final pI1 = ProductIngredient(id: 'pI1', ingredient: i1, quantities: {'pQ1': pQ1});
    pI1.prepareItem();
    final p1 = Product(id: 'p1', name: 'p1', ingredients: {'pI1': pI1});
    p1.prepareItem();
    final c1 = Catalog(id: 'c1', name: 'c1', products: {'p1': p1});
    c1.prepareItem();
    Menu.instance.replaceItems({'c1': c1});

    final r1 = Replenishment(id: 'r1', name: 'r1', data: {'i1': 1});
    Replenisher.instance.replaceItems({'r1': r1});

    final o1 = OrderAttributeOption(id: 'o1', name: 'o1', modeValue: 1);
    final o2 = OrderAttributeOption(id: 'o2', name: 'o2', isDefault: true);
    final cs1 = OrderAttribute(id: 'cs1', name: 'cs1', options: {
      'o1': o1,
      'o2': o2,
    });
    cs1.prepareItem();
    OrderAttributes.instance.replaceItems({'cs1': cs1});
  }

  testWidgets('#preview', (tester) async {
    Stock.instance.replaceItems({'i1': Ingredient(id: 'i1', name: 'i1')});

    // await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    prepareData();

    Future<void> checkPreview(String key, Iterable<String> values) async {
      await tester.tap(find.byKey(Key('sheet_namer.$key.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn.custom')));
      await tester.pumpAndSettle();
      for (var value in values) {
        expect(find.text(value), findsOneWidget);
      }
      await tester.tap(find.byKey(const Key('pop')).last);
      await tester.pumpAndSettle();
    }

    await checkPreview('stock', ['i1']);
    await checkPreview('quantities', ['q1']);
    await checkPreview('menu', ['c1', 'p1', '- i1,0\n  + q1,0,0,0']);
    await checkPreview('replenisher', ['r1', '- i1,1']);
    await checkPreview('orderAttr', ['cs1', '- o1,false,1\n- o2,true,']);
  });

  setUp(() {
    Menu();
    Stock();
    Quantities();
    OrderAttributes();
    Replenisher();
  });
}
