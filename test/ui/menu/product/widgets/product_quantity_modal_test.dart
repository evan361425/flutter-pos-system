import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/widgets/product_quantity_modal.dart';

import '../../../../mocks/mock_models.mocks.dart';
import '../../../../mocks/mock_repos.dart';
import '../../../../mocks/mock_storage.dart';

void main() {
  testWidgets('should update', (tester) async {
    final oldQuantity = Quantity(name: 'qua-1', id: 'qua-1');
    final newQuantity = Quantity(name: 'qua-2', id: 'qua-2');
    final ingredient = MockProductIngredient();
    when(ingredient.prefix).thenReturn('i-id');
    when(ingredient.amount).thenReturn(1);
    when(ingredient.hasQuantity('qua-2')).thenReturn(false);
    when(ingredient.setItem(any)).thenAnswer((_) => Future.value());
    when(quantities.getItem('qua-2')).thenReturn(newQuantity);
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    final quantity = ProductQuantity(
        id: 'qua',
        amount: 1,
        additionalCost: 1,
        additionalPrice: 1,
        ingredient: ingredient,
        quantity: oldQuantity);
    LOG_LEVEL = 0;

    await tester.pumpWidget(MaterialApp(
      routes: {
        // mock search
        Routes.menuQuantitySearch: (_) {
          return FutureBuilder<bool>(
            future: Future.delayed(Duration(milliseconds: 10), () => true),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Navigator.of(context).pop(newQuantity);
              }
              return Container();
            },
          );
        }
      },
      home: ProductQuantityModal(
        ingredient: ingredient,
        quantity: quantity,
      ),
    ));

    // search quantity
    await tester.tap(find.byKey(Key('menu.quantity.search')));
    await tester.pumpAndSettle();
    await tester.pump(Duration(milliseconds: 15));

    // must after search, since it will change amount
    // edit quantity properties
    await tester.enterText(find.byType(TextFormField).at(0), '2');
    await tester.enterText(find.byType(TextFormField).at(1), '2');
    await tester.enterText(find.byType(TextFormField).at(2), '2');

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    final prefix = quantity.prefix;
    verify(storage.set(
        any,
        argThat(equals({
          '$prefix.quantityId': 'qua-2',
          '$prefix.amount': 2,
          '$prefix.additionalCost': 2,
          '$prefix.additionalPrice': 2
        }))));
  });

  testWidgets('should add new item', (tester) async {
    final ingredient = MockProductIngredient();
    final quantity = MockQuantity();
    when(ingredient.prefix).thenReturn('i-id');
    when(ingredient.amount).thenReturn(1);
    when(ingredient.hasQuantity('qua-1')).thenReturn(false);
    when(ingredient.setItem(any)).thenAnswer((_) => Future.value());
    when(quantities.getItem('qua-1')).thenReturn(quantity);
    when(quantity.name).thenReturn('qua-1');
    when(quantity.id).thenReturn('qua-1');
    when(quantity.defaultProportion).thenReturn(1);

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.menuQuantitySearch: (_) {
          return FutureBuilder<bool>(
            future: Future.delayed(Duration(milliseconds: 10), () => true),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Navigator.of(context).pop(quantity);
              }
              return Container();
            },
          );
        }
      },
      home: ProductQuantityModal(ingredient: ingredient),
    ));

    // search quantity
    await tester.tap(find.byKey(Key('menu.quantity.search')));
    await tester.pumpAndSettle();
    await tester.pump(Duration(milliseconds: 15));

    await tester.enterText(find.byType(TextFormField).at(0), '1');
    await tester.enterText(find.byType(TextFormField).at(1), '1');
    await tester.enterText(find.byType(TextFormField).at(2), '1');

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    verify(ingredient.setItem(argThat(predicate<ProductQuantity>((model) {
      return identical(model.ingredient, ingredient) &&
          identical(model.quantity, quantity) &&
          model.amount == 1 &&
          model.additionalCost == 1 &&
          model.additionalPrice == 1;
    }))));
  });

  testWidgets('should pop delete warning', (tester) async {
    final quantity = Quantity(name: 'qua-1', id: 'qua-1');
    final ingredient = MockProductIngredient();
    final productQuantity = ProductQuantity(
      amount: 1,
      additionalCost: 1,
      additionalPrice: 1,
      quantity: quantity,
      ingredient: ingredient,
    );
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    when(ingredient.prefix).thenReturn('prefix');

    await tester.pumpWidget(MaterialApp(
      home: ProductQuantityModal(
        quantity: productQuantity,
        ingredient: ingredient,
      ),
    ));

    // more
    await tester.tap(find.byIcon(KIcons.more));
    await tester.pumpAndSettle();

    // delete
    await tester.tap(find.byIcon(KIcons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    verify(storage.set(any, any));
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
