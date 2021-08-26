import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/cashier/cashier_screen.dart';
import 'package:possystem/ui/cashier/changer/changer_modal.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_repos.dart';

void main() {
  testWidgets('should show changer', (tester) async {
    Cashier.instance = Cashier();

    await tester.pumpWidget(MaterialApp(routes: {
      Routes.cashierChanger: (_) => ChangerModal(),
    }, home: CashierScreen()));

    await tester.tap(find.text('換錢'));
    await tester.pumpAndSettle();

    expect(find.text('套用'), findsOneWidget);

    Cashier.instance = cashier;
  });

  testWidgets('should not show surplus if not set', (tester) async {
    Cashier.instance = Cashier();

    await tester.pumpWidget(MaterialApp(home: CashierScreen()));

    await tester.tap(find.text('結餘'));
    await tester.pumpAndSettle();

    expect(find.text('cancel'), findsNothing);

    Cashier.instance = cashier;
  });

  testWidgets('should show surplus', (tester) async {
    when(cashier.defaultNotSet).thenReturn(false);
    when(cashier.unitLength).thenReturn(0);
    when(cashier.currentTotal).thenReturn(10);
    when(cashier.defaultTotal).thenReturn(10);
    when(cashier.surplus()).thenAnswer((_) => Future.value());
    when(cashier.getDifference()).thenReturn(Iterable.empty());

    await tester.pumpWidget(MaterialApp(home: CashierScreen()));

    await tester.tap(find.text('結餘'));
    await tester.pumpAndSettle();

    expect(find.text('cancel'), findsOneWidget);

    await tester.tap(find.text('confirm'));
    await tester.pumpAndSettle();
  });

  testWidgets('should set default directly', (tester) async {
    when(cashier.defaultNotSet).thenReturn(true);
    when(cashier.unitLength).thenReturn(0);

    await tester.pumpWidget(MaterialApp(home: CashierScreen()));

    await tester.tap(find.text('設為預設'));
    await tester.pumpAndSettle();

    verify(cashier.setDefault(useCurrent: true));
  });

  testWidgets('should show confirm if reset default', (tester) async {
    when(cashier.defaultNotSet).thenReturn(false);
    when(cashier.unitLength).thenReturn(0);

    await tester.pumpWidget(MaterialApp(home: CashierScreen()));

    await tester.tap(find.text('設為預設'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('confirm'));
    await tester.pumpAndSettle();

    verify(cashier.setDefault(useCurrent: true));
  });

  setUp(() {
    when(cache.getRaw(any)).thenReturn(1);
  });

  setUpAll(() {
    initializeRepos();
    initializeCache();
  });
}
