import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/ui/home/home_scaffold.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Home Scaffold', () {
    testWidgets('should navigate correctly', (tester) async {
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(null));
      when(cache.get(any)).thenReturn(null);
      // disable tutorial
      when(cache.get(
        argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
      )).thenReturn(true);
      when(database.query(
        Seller.orderTable,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        join: anyNamed('join'),
        groupBy: anyNamed('groupBy'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) => Future.value([]));
      final settings = SettingsProvider(SettingsProvider.allSettings);

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: Seller.instance),
          ChangeNotifierProvider.value(value: Menu()),
          ChangeNotifierProvider.value(value: Stock()),
          ChangeNotifierProvider.value(value: Quantities()),
          ChangeNotifierProvider.value(value: OrderAttributes()),
          ChangeNotifierProvider.value(value: Cart()),
          ChangeNotifierProvider.value(value: Cashier()),
        ],
        child: MaterialApp(
          routes: Routes.routes,
          navigatorObservers: [MyApp.routeObserver],
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          home: const HomeScaffold(),
        ),
      ));

      Future<void> navAndCheck(String key, String check) async {
        await tester.tap(find.byKey(Key(key)), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.byKey(Key(check)), findsOneWidget);
      }

      Future<void> navAndPop(String key, String check) async {
        await navAndCheck(key, check);

        await tester.tap(find.byIcon(KIcons.back));
        await tester.pumpAndSettle();
      }

      Future<void> dragUp() {
        return tester.dragFrom(const Offset(400, 400), const Offset(0, -200));
      }

      await navAndPop('home_setup.header.menu1', 'menu.add');
      await navAndPop('home_setup.header.menu2', 'menu.add');
      await navAndPop(
          'home_setup.header.order_attrs', 'order_attributes.action');

      // menu for pop to home
      Menu.instance.replaceItems({'1': Catalog(id: '1')});
      await navAndCheck('home_setup.menu', 'menu.add');

      await tester.tap(find.byKey(const Key('catalog.1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.clear_sharp));
      await tester.pumpAndSettle();

      // rest
      await navAndPop('home_setup.exporter', 'exporter.google_sheet');
      await navAndPop('home_setup.quantities', 'quantities.add');
      await navAndPop('home_setup.order_attrs', 'order_attributes.action');
      await dragUp();
      await navAndPop('home_setup.feature_request', 'feature_request_please');
      await dragUp();
      await navAndPop('home_setup.setting', 'setting.theme');
      await navAndPop('home.order', 'order.action.more');
      await navAndCheck('home.stock', 'stock.empty');
      await navAndCheck('home.cashier', 'cashier.changer');
      await navAndCheck('home.analysis', 'analysis.builder');
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
