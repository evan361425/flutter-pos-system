import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/ui/home/home_page.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Home Page', () {
    testWidgets('should navigate correctly', (tester) async {
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(null));
      when(cache.get(any)).thenReturn(null);
      // disable tutorial
      when(cache.get(
        argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
      )).thenReturn(true);
      when(database.query(
        any,
        columns: anyNamed('columns'),
        groupBy: anyNamed('groupBy'),
        orderBy: anyNamed('orderBy'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        escapeTable: anyNamed('escapeTable'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) => Future.value([]));
      final settings = SettingsProvider(SettingsProvider.allSettings);
      final stock = Stock()..replaceItems({'i1': Ingredient(id: 'i1')});

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: Seller.instance),
          ChangeNotifierProvider.value(value: Menu()),
          ChangeNotifierProvider.value(value: stock),
          ChangeNotifierProvider.value(value: Quantities()),
          ChangeNotifierProvider.value(value: OrderAttributes()),
          ChangeNotifierProvider.value(value: Analysis()),
          ChangeNotifierProvider.value(value: Cart()),
          ChangeNotifierProvider.value(value: Cashier()),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(observers: [
            MyApp.routeObserver
          ], routes: [
            GoRoute(
              path: '/',
              routes: Routes.routes,
              builder: (_, __) => const HomePage(tab: HomeTab.setting),
            )
          ]),
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
        ),
      ));

      Future<void> navAndCheck(String key, String check) async {
        await tester.tap(find.byKey(Key(key)), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.byKey(Key(check)), findsOneWidget);
      }

      Future<void> navAndPop(String key, String check) async {
        await navAndCheck(key, check);

        await tester.tap(find.byKey(const Key('pop')));
        await tester.pumpAndSettle();
      }

      Future<void> dragDown() async {
        await tester.dragFrom(const Offset(400, 400), const Offset(0, -200));
        await tester.pumpAndSettle();
      }

      await navAndPop('setting_header.menu1', 'menu.search');
      await navAndPop('setting_header.menu2', 'menu.search');
      await navAndPop('setting_header.order_attrs', 'order_attributes.reorder');

      // rest
      await navAndPop('setting.menu', 'menu.search');
      await navAndPop('setting.exporter', 'transit.google_sheet');
      await navAndPop('setting.quantity', 'quantity.add');
      await navAndPop('setting.order_attrs', 'order_attributes.reorder');
      await dragDown();
      await navAndPop('setting.feature_request', 'feature_request_please');
      await dragDown();
      await navAndPop('setting.setting', 'feature.theme');
      await navAndPop('home.order', 'order.more');
      await navAndCheck('home.stock', 'stock.replenisher');
      await navAndCheck('home.cashier', 'cashier.changer');
      await navAndCheck('home.analysis', 'anal.history');
    });

    setUp(() {
      // setup currency
      when(cache.get('currency')).thenReturn(null);
      CurrencySetting().initialize();

      // setup seller
      when(database.query(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([
            {'totalPrice': 20, 'count': 10},
          ]));
    });

    setUpAll(() {
      initializeAuth();
      initializeCache();
      initializeStorage();
      initializeDatabase();
      initializeTranslator();
    });
  });
}
