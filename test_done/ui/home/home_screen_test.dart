import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/tip/cache_state_manager.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/providers/currency_provider.dart';
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
      var navCount = 0;

      final poper = (BuildContext context) => TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text((++navCount).toString()),
          );

      await tester.pumpWidget(ChangeNotifierProvider.value(
        value: Seller.instance,
        builder: (_, __) => MaterialApp(
          routes: {Routes.menu: poper, Routes.order: poper},
          home: HomeScreen(),
        ),
      ));

      await tester.tap(find.byKey(Key('home.menu')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('home.order')));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
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
