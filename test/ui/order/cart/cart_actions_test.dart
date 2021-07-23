import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/ui/order/cart/cart_actions.dart';

import '../../../mocks/mocks.dart';

void main() {
  testWidgets('discount', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Material(child: CartActions())));
    // open dropdown
    await tester.tap(find.byType(DropdownButtonHideUnderline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('discount').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '30');
    await tester.pumpAndSettle();

    // close dialog
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(cart.updateSelectedDiscount(30));
  });

  testWidgets('change per price', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Material(child: CartActions())));
    // open dropdown
    await tester.tap(find.byType(DropdownButtonHideUnderline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('price').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '30.5');
    await tester.pumpAndSettle();

    // close dialog
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(cart.updateSelectedPrice(30.5));
  });

  testWidgets('change per count', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Material(child: CartActions())));
    // open dropdown
    await tester.tap(find.byType(DropdownButtonHideUnderline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('count').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '30');
    await tester.pumpAndSettle();

    // close dialog
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(cart.updateSelectedCount(30));
  });

  testWidgets('free', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Material(child: CartActions())));
    // open dropdown
    await tester.tap(find.byType(DropdownButtonHideUnderline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('free').last);
    await tester.pumpAndSettle();

    verify(cart.updateSelectedPrice(0));
  });

  testWidgets('delete', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Material(child: CartActions())));
    // open dropdown
    await tester.tap(find.byType(DropdownButtonHideUnderline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('delete').last);
    await tester.pumpAndSettle();

    verify(cart.removeSelected());
  });

  setUpAll(() {
    initialize();
  });
}
