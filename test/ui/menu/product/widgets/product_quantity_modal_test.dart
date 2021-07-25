import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/dialog/delete_dialog.dart';
import 'package:possystem/components/style/search_bar_inline.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product_quantity_model.dart';
import 'package:possystem/models/stock/quantity_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/menu/product/widgets/product_quantity_modal.dart';

import '../../../../mocks/mock_models.mocks.dart';
import '../../../../mocks/mock_repos.dart';
import '../../../../mocks/mock_storage.dart';

void main() {
  testWidgets('should update', (tester) async {
    final oldQuantity = QuantityModel(name: 'qua-1', id: 'qua-1');
    final newQuantity = QuantityModel(name: 'qua-2', id: 'qua-2');
    final ingredient = MockProductIngredientModel();
    when(ingredient.prefix).thenReturn('i-id');
    when(ingredient.amount).thenReturn(1);
    when(ingredient.hasItem('qua-2')).thenReturn(false);
    when(ingredient.setItem(any)).thenAnswer((_) => Future.value());
    when(quantities.getItem('qua-2')).thenReturn(newQuantity);
    when(storage.set(any, any)).thenAnswer((_) => Future.value());
    final quantity = ProductQuantityModel(
        amount: 1,
        additionalCost: 1,
        additionalPrice: 1,
        ingredient: ingredient,
        quantity: oldQuantity);
    LOG_LEVEL = 0;

    await tester.pumpWidget(MaterialApp(
      routes: {
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
    await tester.tap(find.byType(SearchBarInline));
    await tester.pumpAndSettle();
    await tester.pump(Duration(milliseconds: 15));

    // must after search, since it will change amount
    await tester.enterText(find.byType(TextFormField).first, '2');
    await tester.enterText(find.byType(TextFormField).at(1), '2');
    await tester.enterText(find.byType(TextFormField).at(2), '2');

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    verify(ingredient.removeItem('qua-1'));
    verify(storage.set(any, argThat(equals({'i-id.quantities.qua-1': null}))));
    verify(ingredient.setItem(argThat(predicate<ProductQuantityModel?>((model) {
      return model?.id == 'qua-2' &&
          model?.additionalCost == 2 &&
          model?.additionalPrice == 2 &&
          model?.amount == 2;
    }))));
  });

  testWidgets('should add new item', (tester) async {
    final ingredient = MockProductIngredientModel();
    final quantity = MockQuantityModel();
    when(ingredient.prefix).thenReturn('i-id');
    when(ingredient.amount).thenReturn(1);
    when(ingredient.hasItem('qua-1')).thenReturn(false);
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

    // search ingredient
    await tester.tap(find.byType(SearchBarInline));
    await tester.pumpAndSettle();
    await tester.pump(Duration(milliseconds: 15));

    await tester.enterText(find.byType(TextFormField).first, '1');
    await tester.enterText(find.byType(TextFormField).at(1), '1');
    await tester.enterText(find.byType(TextFormField).at(2), '1');

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    verify(ingredient.setItem(argThat(predicate<ProductQuantityModel>((model) {
      return identical(model.ingredient, ingredient) &&
          model.amount == 1 &&
          model.additionalCost == 1 &&
          model.additionalPrice == 1;
    }))));
  });

  testWidgets('should pop delete warning', (tester) async {
    final quantity = QuantityModel(name: 'qua-1', id: 'qua-1');
    final ingredient = MockProductIngredientModel();
    final productQuantity = ProductQuantityModel(
      amount: 1,
      additionalCost: 1,
      additionalPrice: 1,
      quantity: quantity,
      ingredient: ingredient,
    );

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

    expect(find.byType(DeleteDialog), findsOneWidget);
  });

  setUpAll(() {
    initializeRepos();
    initializeStorage();
  });
}
