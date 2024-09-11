import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/cashier/cashier_view.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Cashier View', () {
    Widget buildApp() {
      // setup currency and cashier relation
      when(cache.get(any)).thenReturn(null);
      // disable tutorial
      when(cache.get(
        argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
      )).thenReturn(true);
      when(storage.get(any, any)).thenAnswer((_) => Future.value({}));

      return ChangeNotifierProvider.value(
        value: Cashier.instance,
        builder: (_, __) => MaterialApp.router(
          routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => const Scaffold(body: CashierView()),
            ),
            ...Routes.getDesiredRoute(0).routes,
          ]),
        ),
      );
    }

    testWidgets('should execute changer', (tester) async {
      await Cashier.instance.setCurrent(<Map<String, num>>[
        {'unit': 1, 'count': 10},
        {'unit': 5, 'count': 5},
      ]);
      await Cashier.instance.setFavorite(<Map<String, Object?>>[
        {
          'source': {'unit': 5, 'count': 1},
          'targets': [
            {'unit': 1, 'count': 5},
          ],
        },
      ]);

      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('cashier.changer')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('changer.favorite.0')));
      await tester.tap(find.byKey(const Key('changer.apply')));
      await tester.pumpAndSettle();

      expect(Cashier.instance.at(0).count, 15);
      expect(Cashier.instance.at(1).count, 4);
      expect(Cashier.instance.favoriteItems().first.hashCode, 0);
    });

    testWidgets('should not show surplus if not initialized', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('cashier.surplus')));
      await tester.pumpAndSettle();

      expect(find.text(S.cashierSurplusErrorEmptyDefault), findsOneWidget);
    });

    testWidgets('should execute surplus', (tester) async {
      await Cashier.instance.setCurrent(<Map<String, num>>[
        {'unit': 1, 'count': 15},
        {'unit': 5, 'count': 4},
      ]);
      await Cashier.instance.setDefault(<Map<String, num>>[
        {'unit': 1, 'count': 10},
        {'unit': 5, 'count': 5},
      ]);

      when(storage.set(any, any)).thenAnswer((_) => Future.value());

      await tester.pumpWidget(buildApp());

      expect(Cashier.instance.at(0).count, equals(15));
      expect(Cashier.instance.at(1).count, equals(4));

      await tester.tap(find.byKey(const Key('cashier.surplus')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('text_dialog.text')), '13');
      await tester.tap(find.byKey(const Key('text_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(Cashier.instance.at(0).count, equals(13));

      await tester.tap(find.byKey(const Key('cashier_surplus.confirm')));
      await tester.pumpAndSettle();

      expect(Cashier.instance.at(0).count, equals(10));
      expect(Cashier.instance.at(1).count, equals(5));
    });

    testWidgets('should able to set default', (tester) async {
      await Cashier.instance.setCurrent(<Map<String, num>>[
        {'unit': 1, 'count': 10},
        {'unit': 5, 'count': 5},
      ]);
      await tester.pumpWidget(buildApp());

      action(
        String unit,
        String number, [
        String action = 'confirm',
      ]) async {
        await tester.tap(find.text(S.cashierUnitLabel(unit)));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), number);
        await tester.tap(find.byKey(Key('slider_dialog.$action')));
        await tester.pumpAndSettle();
      }

      await action('1', '13');
      expect(find.text('13／0'), findsOneWidget);

      await action('5', '2');
      await action('5', '5', 'cancel');
      expect(find.text('2／0'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cashier.defaulter')));
      await tester.pumpAndSettle();

      expect(Cashier.instance.at(0).count, equals(13));
      expect(Cashier.instance.at(1).count, equals(2));
    });

    testWidgets('should show confirm if reset default', (tester) async {
      await Cashier.instance.setCurrent(<Map<String, num>>[
        {'unit': 1, 'count': 15},
        {'unit': 5, 'count': 4},
      ]);
      await Cashier.instance.setDefault(<Map<String, num>>[
        {'unit': 1, 'count': 10},
        {'unit': 5, 'count': 5},
      ]);

      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('cashier.defaulter')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.cancel')));
      await tester.pumpAndSettle();

      // default value not set
      expect(Cashier.instance.getDifference().first.defaultCount, equals(10));

      await tester.tap(find.byKey(const Key('cashier.defaulter')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
      await tester.pumpAndSettle();
      expect(Cashier.instance.getDifference().first.defaultCount, equals(15));
    });

    setUp(() {
      Cashier();
    });

    setUpAll(() {
      initializeStorage();
      initializeCache();
      initializeTranslator();
    });
  });
}
