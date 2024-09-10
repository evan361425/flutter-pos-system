import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/replenishment_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Replenishment Page', () {
    Widget buildApp(Stock stock, Replenisher replenisher) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<Stock>.value(value: stock),
          ChangeNotifierProvider<Replenisher>.value(value: replenisher),
        ],
        builder: (_, __) => MaterialApp.router(
          routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const ReplenishmentPage(),
            ),
            ...Routes.getDesiredRoute(0).routes,
          ]),
        ),
      );
    }

    testWidgets('Edit replenishment', (tester) async {
      final replenishment = Replenishment(id: 'r-1', name: 'r-1', data: {
        'i-1': 1,
        'i-2': 2,
      });
      final ing1 = Ingredient(id: 'i-1', name: 'i-1');
      final ing2 = Ingredient(id: 'i-2', name: 'i-2');
      final stock = Stock()..replaceItems({'i-1': ing1, 'i-2': ing2});
      final replenisher = Replenisher()
        ..replaceItems({
          'r-1': replenishment,
          'r-2': Replenishment(id: 'r-2', name: 'r-2'),
        });
      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      await tester.pumpWidget(buildApp(stock, replenisher));

      await tester.longPress(find.byKey(const Key('replenisher.r-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(KIcons.edit));
      await tester.pumpAndSettle();

      // should failed
      await tester.enterText(find.byKey(const Key('replenishment.name')), 'r-2');
      await tester.tap(find.byKey(const Key('modal.save')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('replenishment.name')), 'r-3');
      await tester.enterText(find.byKey(const Key('replenishment.ingredients.i-1')), '2');
      await tester.enterText(find.byKey(const Key('replenishment.ingredients.i-2')), '3');
      await tester.tap(find.byKey(const Key('modal.save')));
      // update to storage
      await tester.pumpAndSettle();
      // pop
      await tester.pumpAndSettle();

      final w = find.byKey(const Key('replenisher.r-1')).evaluate().first.widget;
      expect(((w as ListTile).title as Text).data, equals('r-3'));
      expect(replenishment.getNumOfId('i-1'), equals(2));
      expect(replenishment.getNumOfId('i-2'), equals(3));
    });

    testWidgets('Add replenishment', (tester) async {
      final ing1 = Ingredient(id: 'i-1', name: 'i-1');
      final ing2 = Ingredient(id: 'i-2', name: 'i-2');
      final stock = Stock()..replaceItems({'i-1': ing1, 'i-2': ing2});
      final replenisher = Replenisher()..replaceItems({});
      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      await tester.pumpWidget(buildApp(stock, replenisher));

      await tester.tap(find.byKey(const Key('empty_body')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('replenishment.name')), 'r-1');
      await tester.enterText(find.byKey(const Key('replenishment.ingredients.i-1')), '1');
      await tester.enterText(find.byKey(const Key('replenishment.ingredients.i-2')), '2');
      await tester.tap(find.byKey(const Key('modal.save')));
      // save to storage
      await tester.pumpAndSettle();
      // pop
      await tester.pumpAndSettle();

      final replenishment = replenisher.items.first;
      final w = find.byKey(Key('replenisher.${replenishment.id}')).evaluate().first.widget;

      expect(((w as ListTile).title as Text).data, equals('r-1'));
      expect(replenishment.getNumOfId('i-1'), equals(1));
      expect(replenishment.getNumOfId('i-2'), equals(2));
    });

    testWidgets('Delete replenishment', (tester) async {
      final replenishment = Replenishment(id: 'r-1', name: 'r-1');
      final replenisher = Replenisher()..replaceItems({'r-1': replenishment});
      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      await tester.pumpWidget(buildApp(Stock(), replenisher));

      await tester.longPress(find.byKey(const Key('replenisher.r-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn.delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('replenisher.r-1')), findsNothing);
    });

    setUpAll(() {
      initializeStorage();
      initializeTranslator();
    });
  });
}
