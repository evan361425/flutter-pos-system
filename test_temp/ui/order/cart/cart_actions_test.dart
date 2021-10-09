import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/ui/order/cart/cart_actions.dart';

import '../../../mocks/mock_repos.dart';

void main() {
  testWidgets('discount', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CartActions()));
    // open dropdown
    await tester.tap(find.text('action_hint'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('discount'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '30');
    await tester.pumpAndSettle();

    // close dialog
    await tester.tap(find.text('confirm'));
    await tester.pumpAndSettle();

    verify(cart.updateSelectedDiscount(30));
  });

  testWidgets('change per price', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CartActions()));
    // open dropdown
    await tester.tap(find.text('action_hint'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('price'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '30.5');
    await tester.pumpAndSettle();

    // close dialog
    await tester.tap(find.text('confirm'));
    await tester.pumpAndSettle();

    verify(cart.updateSelectedPrice(30.5));
  });

  testWidgets('change per count', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CartActions()));
    // open dropdown
    await tester.tap(find.text('action_hint'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('count'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '30');
    await tester.pumpAndSettle();

    // close dialog
    await tester.tap(find.text('confirm'));
    await tester.pumpAndSettle();

    verify(cart.updateSelectedCount(30));
  });

  testWidgets('free', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CartActions()));
    // open dropdown
    await tester.tap(find.text('action_hint'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('free'));
    await tester.pumpAndSettle();

    verify(cart.updateSelectedPrice(0));
  });

  testWidgets('delete', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CartActions()));
    // open dropdown
    await tester.tap(find.text('action_hint'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    verify(cart.removeSelected());
  });

  setUpAll(() {
    initializeRepos();
  });
}
