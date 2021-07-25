import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/widgets/replenishment_actions.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_repos.dart';

void main() {
  testWidgets('should loading if not ready', (tester) async {
    when(replenisher.isReady).thenReturn(false);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<Replenisher>.value(value: replenisher),
    ], child: MaterialApp(home: ReplenishmentActions())));

    expect(find.byType(CircularLoading), findsOneWidget);
  });

  testWidgets('should do nothing if add replenishment in default',
      (tester) async {
    when(replenisher.isReady).thenReturn(true);
    when(replenisher.items).thenReturn([]);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<Replenisher>.value(value: replenisher),
    ], child: MaterialApp(home: Material(child: ReplenishmentActions()))));

    await tester.tap(find.byIcon(Icons.add_circle_outline_sharp));

    expect(find.byType(ConfirmDialog), findsNothing);
  });

  testWidgets('should navigate if edit replenishment in default',
      (tester) async {
    when(replenisher.isReady).thenReturn(true);
    when(replenisher.items).thenReturn([]);

    var navigateCount = 0;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<Replenisher>.value(value: replenisher),
        ],
        child: MaterialApp(
          routes: {
            Routes.stockReplenishmentModal: (context) {
              expect(ModalRoute.of(context)!.settings.arguments, isNull);
              return Text((navigateCount++).toString());
            },
          },
          home: Material(child: ReplenishmentActions()),
        )));

    await tester.tap(find.byIcon(KIcons.edit));
    await tester.pumpAndSettle();

    expect(navigateCount, equals(1));
  });

  testWidgets('should show confirm when select', (tester) async {
    final repl = Replenishment(name: 'name', id: 'id', data: {'ing-1': 20});
    final ingredient = Ingredient(name: 'ing-name', id: 'ing-1');
    when(replenisher.isReady).thenReturn(true);
    when(replenisher.items).thenReturn([repl]);
    when(replenisher.getItem('id')).thenReturn(repl);
    when(stock.getItem('ing-1')).thenReturn(ingredient);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<Replenisher>.value(value: replenisher),
    ], child: MaterialApp(home: Material(child: ReplenishmentActions()))));

    // show drop down
    await tester.tap(find.byKey(ReplenishmentActions.selector));
    await tester.pumpAndSettle();

    // select replenishment
    await tester.tap(find.text('name').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle_outline_sharp));
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmDialog), findsOneWidget);
    expect(find.text('- ing-name'), findsOneWidget);
  });

  setUpAll(() {
    initializeRepos();
  });
}
