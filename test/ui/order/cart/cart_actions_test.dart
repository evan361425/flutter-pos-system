import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/ui/order/cart/cart_actions.dart';

import '../../../mocks/mock_cart.dart';

void main() {
  testWidgets('discount', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Material(child: CartActions())));
    // open dropdown
    await tester.tap(find.byType(DropdownButtonHideUnderline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('打折').last);
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

    await tester.tap(find.text('變價').last);
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

    await tester.tap(find.text('變更數量').last);
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

    await tester.tap(find.text('招待').last);
    await tester.pumpAndSettle();

    verify(cart.updateSelectedPrice(0));
  });

  testWidgets('delete', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Material(child: CartActions())));
    // open dropdown
    await tester.tap(find.byType(DropdownButtonHideUnderline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('刪除').last);
    await tester.pumpAndSettle();

    verify(cart.removeSelected());
  });

  setUpAll(() {
    initializeCart();
  });
}
