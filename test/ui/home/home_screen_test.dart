import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/order_outlook_setting.dart';
import 'package:possystem/settings/setting.dart';
import 'package:possystem/settings/theme_setting.dart';
import 'package:possystem/ui/home/home_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/disable_tips.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Home Screen', () {
    testWidgets('should reset info after update', (tester) async {
      when(database.push(any, any)).thenAnswer((_) => Future.value(1));

      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: Seller.instance,
        builder: (_, __) => const MaterialApp(home: HomeScreen()),
      ));
      // wait for query order from DB
      await tester.pumpAndSettle();

      expect(find.text('20'), findsOneWidget);

      when(database.query(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([
            {'totalPrice': 40, 'count': 30},
          ]));

      await Seller.instance.push(OrderObject(
        totalPrice: 1,
        productsPrice: 1,
        totalCount: 1,
        products: [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('should navigate correctly', (tester) async {
      when(cache.get(any)).thenReturn(null);
      when(cache.get(argThat(predicate<String>((f) => f.startsWith('_tip')))))
          .thenReturn(1);
      when(database.query(
        Seller.orderTable,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        groupBy: argThat(isNotNull, named: 'groupBy'),
      )).thenAnswer((_) => Future.value([]));
      final settings = SettingsProvider([
        CurrencySetting.instance,
        ThemeSetting(),
        LanguageSetting(),
        OrderOutlookSetting(),
        OrderAwakeningSetting()
      ]);

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings..loadSetting()),
          ChangeNotifierProvider.value(value: Seller.instance),
          ChangeNotifierProvider.value(value: Menu()),
          ChangeNotifierProvider.value(value: Stock()),
          ChangeNotifierProvider.value(value: Quantities()),
          ChangeNotifierProvider.value(value: CustomerSettings()),
          ChangeNotifierProvider.value(value: Cart()),
          ChangeNotifierProvider.value(value: Cashier()),
        ],
        child: MaterialApp(
          routes: Routes.routes,
          navigatorObservers: [MyApp.routeObserver],
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          home: const HomeScreen(),
        ),
      ));

      navAndPop(String key, String check) async {
        await tester.tap(find.byKey(Key('home.$key')));
        await tester.pumpAndSettle();

        expect(find.byKey(Key(check)), findsOneWidget);

        await tester.tap(find.byIcon(KIcons.back));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const Key('home.order')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.action.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.action.leave')));
      await tester.pumpAndSettle();

      await navAndPop('menu', 'menu.add');
      await navAndPop('stock', 'stock.add');
      await navAndPop('quantities', 'quantities.add');
      await navAndPop('cashier', 'cashier.changer');
      await navAndPop('customer', 'customer_settings.action');
      await navAndPop('analysis', 'analysis_screen');
      await navAndPop('setting', 'setting.theme');
    });

    setUp(() {
      // setup currency
      when(cache.get('currency')).thenReturn(null);
      CurrencySetting().initialize();

      // setup seller
      Seller();
      when(database.query(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([
            {'totalPrice': 20, 'count': 10},
          ]));

      disableTips();
    });

    setUpAll(() {
      initializeCache();
      initializeStorage();
      initializeDatabase();
      initializeTranslator();
    });
  });
}
