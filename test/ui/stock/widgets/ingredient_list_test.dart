import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/widgets/ingredient_list.dart';

import '../../../mocks/mocks.dart';

void main() {
  testWidgets('should navigate', (tester) async {
    final ingredient = IngredientModel(name: 'name', id: 'id');
    var argument;

    await tester.pumpWidget(MaterialApp(
      routes: {
        Routes.stockIngredient: (context) {
          argument = ModalRoute.of(context)!.settings.arguments;
          return Container();
        },
      },
      home: IngredientList(ingredients: [ingredient]),
    ));

    // tap tile
    await tester.tap(find.text('name'));
    await tester.pumpAndSettle();

    expect(identical(ingredient, argument), isTrue);
  });

  testWidgets('should add ingredient', (tester) async {
    final ingredient = IngredientModel(name: 'name', id: 'id');
    when(stock.applyAmounts({'id': 20})).thenAnswer((_) => Future.value());

    await tester.pumpWidget(
        MaterialApp(home: IngredientList(ingredients: [ingredient])));

    // tap add icon
    await tester.tap(find.byIcon(KIcons.add));
    await tester.pumpAndSettle();

    // enter amount
    await tester.enterText(find.byType(TextFormField), '20');
    await tester.tap(find.byType(ElevatedButton).last);

    verify(stock.applyAmounts(any));
  });

  testWidgets('should minus ingredient', (tester) async {
    final ingredient = IngredientModel(name: 'name', id: 'id');
    when(stock.applyAmounts({'id': -20})).thenAnswer((_) => Future.value());

    await tester.pumpWidget(
        MaterialApp(home: IngredientList(ingredients: [ingredient])));

    // tap add icon
    await tester.tap(find.byIcon(KIcons.remove));
    await tester.pumpAndSettle();

    // enter amount
    await tester.enterText(find.byType(TextFormField), '20');
    await tester.tap(find.byType(ElevatedButton).last);

    verify(stock.applyAmounts(any));
  });

  setUpAll(() {
    initialize();
  });
}
