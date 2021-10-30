import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/setting.dart';
import 'package:possystem/ui/cashier/cashier_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/disable_tips.dart';

void main() {
  group('Cashier Screen', () {
    Widget buildApp() {
      // setup currency and cashier relation
      when(cache.get(any)).thenReturn(null);
      when(storage.get(any, any)).thenAnswer((_) => Future.value({}));

      final settings = SettingsProvider([CurrencySetting.instance]);

      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Cashier.instance),
          ChangeNotifierProvider.value(value: settings..loadSetting()),
        ],
        builder: (_, __) => MaterialApp(
          routes: Routes.routes,
          home: MaterialApp(
            routes: Routes.routes,
            home: const CashierScreen(),
          ),
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

      await tester.tap(find.byKey(const Key('cashier.changer.favorite.0')));
      await tester.tap(find.byKey(const Key('cashier.changer.apply')));
      await tester.pumpAndSettle();

      expect(Cashier.instance.at(0).count, equals(15));
      expect(Cashier.instance.at(1).count, equals(4));
    });

    testWidgets('should not show surplus if not initialized', (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.tap(find.byKey(const Key('cashier.surplus')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
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

      await tester.tap(find.text('confirm'));
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
        String type,
        String number, [
        String action = 'confirm',
      ]) async {
        await tester.tap(find.byKey(Key('cashier.$type')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), number);
        await tester.tap(find.byKey(Key('text_dialog.$action')));
        await tester.pumpAndSettle();
      }

      await action('1.plus', '3');
      await action('5.minus', '7');
      await action('5.plus', '5', 'cancel');

      final w1 = find
          .byKey(const Key('cashier.1.count'))
          .evaluate()
          .single
          .widget as Text;
      final w5 = find
          .byKey(const Key('cashier.5.count'))
          .evaluate()
          .single
          .widget as Text;
      expect(w1.data, equals('數量：13'));
      expect(w5.data, equals('數量：0'));

      await tester.tap(find.byKey(const Key('cashier.defaulter')));
      await tester.pumpAndSettle();

      expect(Cashier.instance.at(0).count, equals(13));
      expect(Cashier.instance.at(1).count, isZero);
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
      expect(Cashier.instance.getDifference().first[1].count, equals(10));

      await tester.tap(find.byKey(const Key('cashier.defaulter')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
      await tester.pumpAndSettle();
      expect(Cashier.instance.getDifference().first[1].count, equals(15));
    });

    setUp(() {
      CurrencySetting();
      Cashier();
    });

    setUpAll(() {
      disableTips();
      initializeStorage();
      initializeCache();
    });
  });
}
