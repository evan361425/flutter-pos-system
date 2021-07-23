import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/ui/order/cashier/calculator_dialog.dart';

import '../../../mocks/mocks.dart';
import '../../../mocks/mock_widgets.dart';
import '../../../mocks/providers.dart';

void main() {
  testWidgets('use total price if not set', (tester) async {
    when(cart.totalPrice).thenReturn(20);
    when(cart.isHistoryMode).thenReturn(false);
    when(currency.isInt).thenReturn(true);

    await tester.pumpWidget(bindWithNavigator(CalculatorDialog()));

    await tester.tap(find.byIcon(Icons.done_rounded));

    verify(cart.paid(null));
  });

  testWidgets('tap 1~9 and show change', (tester) async {
    when(cart.totalPrice).thenReturn(123456788);
    when(cart.isHistoryMode).thenReturn(false);
    when(currency.isInt).thenReturn(true);
    when(currency.numToString(1)).thenReturn('1');

    await tester.pumpWidget(bindWithNavigator(CalculatorDialog()));

    await tester.tap(find.text('1').last);
    await tester.tap(find.text('2').last);
    await tester.tap(find.text('3').last);
    await tester.tap(find.text('4').last);
    await tester.tap(find.text('5').last);
    await tester.tap(find.text('6').last);
    await tester.tap(find.text('7').last);
    await tester.tap(find.text('8').last);
    await tester.tap(find.text('9').last);

    final paid = tester.widget(find.byType(TextField).last) as TextField;

    expect(paid.controller?.text, equals('123456789'));
    verify(currency.numToString(1));
  });

  testWidgets('tap back', (tester) async {
    when(cart.totalPrice).thenReturn(30);
    when(cart.isHistoryMode).thenReturn(false);
    when(currency.isInt).thenReturn(true);

    await tester.pumpWidget(bindWithNavigator(CalculatorDialog()));

    await tester.tap(find.text('1').last);
    await tester.tap(find.text('2').last);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).last);

    final paid = tester.widget(find.byType(TextField).last) as TextField;

    expect(paid.controller?.text, equals('1'));
  });

  testWidgets('tap clear', (tester) async {
    when(cart.totalPrice).thenReturn(30);
    when(cart.isHistoryMode).thenReturn(false);
    when(currency.isInt).thenReturn(true);

    await tester.pumpWidget(bindWithNavigator(CalculatorDialog()));

    await tester.tap(find.text('1').last);
    await tester.tap(find.text('2').last);
    await tester.tap(find.byIcon(KIcons.clear).last);

    final paid = tester.widget(find.byType(TextField).last) as TextField;

    expect(paid.controller?.text, equals(''));
  });

  testWidgets('tap ceil', (tester) async {
    when(cart.totalPrice).thenReturn(30);
    when(cart.isHistoryMode).thenReturn(false);
    when(currency.isInt).thenReturn(true);
    when(currency.ceil(30)).thenReturn(50);
    // change
    when(currency.numToString(20)).thenReturn('20');
    when(currency.numToString(50)).thenReturn('50');

    await tester.pumpWidget(bindWithNavigator(CalculatorDialog()));

    await tester.tap(find.byIcon(Icons.merge_type_rounded).last);

    final paid = tester.widget(find.byType(TextField).last) as TextField;

    expect(paid.controller?.text, equals('50'));
  });

  testWidgets('tap done and lock action', (tester) async {
    when(cart.totalPrice).thenReturn(20);
    when(cart.isHistoryMode).thenReturn(false);
    when(currency.isInt).thenReturn(true);
    when(cart.paid(null))
        .thenAnswer((_) => Future.delayed(Duration(milliseconds: 10)));

    await tester.pumpWidget(bindWithNavigator(CalculatorDialog()));

    await tester.tap(find.byIcon(Icons.done_rounded));
    await tester.pump(Duration(milliseconds: 5));
    // no mock ceil to confirm it is not fired
    await tester.tap(find.byIcon(Icons.merge_type_rounded));

    await tester.pumpAndSettle();
  });

  testWidgets('show confrim in history mode', (tester) async {
    when(cart.totalPrice).thenReturn(20);
    when(cart.isHistoryMode).thenReturn(true);
    when(currency.isInt).thenReturn(true);

    await tester.pumpWidget(bindWithNavigator(CalculatorDialog()));

    await tester.tap(find.byIcon(Icons.done_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(cart.paid(null));
  });

  testWidgets('should fail if paid too low and unlock', (tester) async {
    when(cart.totalPrice).thenReturn(20);
    when(cart.isHistoryMode).thenReturn(false);
    when(currency.isInt).thenReturn(true);
    when(currency.numToString(13)).thenReturn('13');
    when(cart.paid(30)).thenAnswer((_) => Future.value());
    when(cart.paid(3))
        .thenAnswer((_) => Future.delayed(Duration(milliseconds: 10), () {
              throw 'too low';
            }));

    await tester.pumpWidget(bindWithNavigator(CalculatorDialog()));

    await tester.tap(find.text('3').last);
    await tester.tap(find.byIcon(Icons.done_rounded));
    await tester.pump(Duration(milliseconds: 5));
    // no mock ceil to confirm it is not fired
    await tester.tap(find.byIcon(Icons.merge_type_rounded));

    await tester.pumpAndSettle();

    // paid 33 to confirm unlock
    await tester.tap(find.text('3').last);
    await tester.tap(find.byIcon(Icons.done_rounded));

    verify(cart.paid(33));
  });

  setUpAll(() {
    initialize();
    initializeProviders();
  });
}
