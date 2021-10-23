import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/tip/cache_state_manager.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/home/home_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/disable_tips.dart';

void main() {
  group('Home Screen', () {
    testWidgets('should show tip correctly', (tester) async {
      CacheStateManager.initialize();
      when(cache.getRaw(any)).thenReturn(1);
      when(cache.getRaw('_tip.home.menu')).thenReturn(0);
      when(cache.getRaw('_tip.home.order')).thenReturn(0);
      when(cache.setRaw(any, any)).thenAnswer((_) => Future.value(true));

      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: Seller.instance,
        builder: (_, __) => MaterialApp(home: HomeScreen()),
      ));
      // show menu tip animation
      await tester.pumpAndSettle();

      when(cache.getRaw('_tip.home.menu')).thenReturn(1);

      // close tip
      await tester.tapAt(Offset(0, 0));
      await tester.pumpAndSettle();

      verify(cache.setRaw('_tip.home.menu', isNonZero));

      // close order tip
      when(cache.getRaw('_tip.home.order')).thenReturn(1);

      // close tip
      await tester.tapAt(Offset(0, 0));
      await tester.pumpAndSettle();

      verify(cache.setRaw('_tip.home.order', isNonZero));
    });

    testWidgets('should reset info after update', (tester) async {
      when(database.push(any, any)).thenAnswer((_) => Future.value(1));
      disableTips();

      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: Seller.instance,
        builder: (_, __) => MaterialApp(home: HomeScreen()),
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
      disableTips();
      when(cache.get(any)).thenReturn(null);
      when(cache.getRaw(any)).thenReturn(1);
      when(database.query(
        Seller.ORDER_TABLE,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        groupBy: argThat(isNotNull, named: 'groupBy'),
      )).thenAnswer((_) => Future.value([]));

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ThemeProvider()..initialize()),
          ChangeNotifierProvider.value(value: LanguageProvider()..initialize()),
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
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          locale: Locale('zh', 'TW'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: HomeScreen(),
        ),
      ));

      final navAndPop = (String key, String check) async {
        await tester.tap(find.byKey(Key('home.$key')));
        await tester.pumpAndSettle();

        expect(find.byKey(Key(check)), findsOneWidget);

        await tester.tap(find.byIcon(KIcons.back));
        await tester.pumpAndSettle();
      };

      await tester.tap(find.byKey(Key('home.order')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('order.action.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('order.action.leave')));
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
      LOG_LEVEL = 0;
      // setup currency
      final currency = CurrencyProvider();
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
      currency.setCurrency(CurrencyTypes.TWD);

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
      initializeCache();
      initializeStorage();
      initializeDatabase();
    });
  });
}
