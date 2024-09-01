import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/history_order_list.dart';
import 'package:possystem/ui/analysis/widgets/history_order_modal.dart';

import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_database.dart';
import '../../../mocks/mock_database.mocks.dart';
import '../../../mocks/mock_storage.dart';
import '../../../test_helpers/order_setter.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('History Order List', () {
    Widget buildApp(ValueNotifier<DateTimeRange> notifier) {
      when(cache.get(any)).thenReturn(null);
      when(cache.get(
        argThat(predicate((String e) => e.startsWith('tutorial.'))),
      )).thenReturn(true);
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (_, __) {
              return Material(
                child: HistoryOrderList(notifier: notifier),
              );
            },
          ),
          ...Routes.getDesiredRoute(0).routes,
        ]),
      );
    }

    dynamic mockGetOrders() {
      return database.query(
        Seller.orderTable,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
        limit: argThat(equals(10), named: 'limit'),
        offset: anyNamed('offset'),
        join: anyNamed('join'),
        groupBy: anyNamed('groupBy'),
      );
    }

    testWidgets('should show progress when initializing', (tester) async {
      var loadCount = 0;

      when(mockGetOrders()).thenAnswer((_) {
        loadCount++;
        return Future.delayed(
          const Duration(milliseconds: 100),
          () => Future.value(<Map<String, Object?>>[]),
        );
      });
      OrderSetter.setMetrics([]);

      await tester.pumpWidget(buildApp(ValueNotifier(Util.getDateRange())));
      await tester.pump(const Duration(milliseconds: 10));

      expect(find.byType(CircularLoading), findsOneWidget);
      expect(loadCount, equals(1));

      await tester.pumpAndSettle();

      // should not set progress if empty result
      expect(find.byType(CircularLoading), findsNothing);
      expect(find.text(S.orderLoaderEmpty), findsOneWidget);
      expect(loadCount, equals(1));
    });

    testWidgets('should load more and refresh', (tester) async {
      final data = List<Map<String, int>>.generate(21, (i) => {});
      final notifier = ValueNotifier(Util.getDateRange());
      var loadCount = 0;

      when(mockGetOrders()).thenAnswer((_) {
        return Future.value(loadCount * 10 > data.length
            ? <Map<String, int>>[]
            : data.sublist(
                loadCount++ * 10,
                min(loadCount * 10, data.length),
              ));
      });
      OrderSetter.setMetrics([]);

      await tester.pumpWidget(buildApp(notifier));
      await tester.pumpAndSettle();

      expect(loadCount, equals(2));

      final center = tester.getCenter(find.byKey(const Key('item_loader')));

      await tester.dragFrom(center, const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(loadCount, equals(3));

      // touch limit and finish loading
      await tester.dragFrom(center, const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(loadCount, equals(3));

      // reset range
      loadCount = 0;
      notifier.value = Util.getDateRange(days: 2);
      await tester.pumpAndSettle();

      expect(loadCount, equals(2));
    });

    testWidgets('should navigate to modal', (tester) async {
      final order = OrderSetter.sample();
      // test showing product name without count
      order.products.add(const OrderProductObject(count: 1));
      OrderSetter.setMetrics([order]);
      OrderSetter.setOrders([order]);
      OrderSetter.setOrder(order);

      await tester.pumpWidget(buildApp(ValueNotifier(Util.getDateRange())));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('history.order.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order.attributes')));
      await tester.pumpAndSettle();

      expect(find.text('oa-1'), findsOneWidget);
      expect(find.text('oao-1'), findsOneWidget);
      expect(find.text('p-2'), findsOneWidget);

      await tester.tap(find.text(S.orderObjectViewPriceTotal('40')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pop')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('history.order.1')), findsOneWidget);
    });

    testWidgets('should delete order', (tester) async {
      final order = OrderSetter.sample();
      OrderSetter.setMetrics([order]);
      OrderSetter.setOrders([order]);
      OrderSetter.setOrder(order);

      await tester.pumpWidget(buildApp(ValueNotifier(Util.getDateRange())));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('history.order.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('order_modal.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn.delete')));
      await tester.pumpAndSettle();

      final txn = MockDatabaseExecutor();
      when(txn.delete(
        Seller.orderTable,
        where: argThat(equals('id = 1'), named: 'where'),
      )).thenAnswer((_) => Future.value(1));
      when(txn.delete(
        Seller.productTable,
        where: argThat(equals('orderId = 1'), named: 'where'),
      )).thenAnswer((_) => Future.value(1));
      when(txn.delete(
        Seller.ingredientTable,
        where: argThat(equals('orderId = 1'), named: 'where'),
      )).thenAnswer((_) => Future.value(1));
      when(txn.delete(
        Seller.attributeTable,
        where: argThat(equals('orderId = 1'), named: 'where'),
      )).thenAnswer((_) => Future.value(1));
      when(database.transaction(any)).thenAnswer((inv) => inv.positionalArguments[0](txn));

      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      verify(txn.delete(any, where: anyNamed('where'))).called(4);
    });

    testWidgets('order not found', (tester) async {
      when(database.query(any, where: argThat(equals('id = 666'), named: 'where'))).thenAnswer((_) => Future.value([]));

      await tester.pumpWidget(const MaterialApp(home: HistoryOrderModal(666)));
      await tester.pumpAndSettle();

      expect(find.text(S.analysisHistoryOrderNotFound), findsOneWidget);
    });

    setUpAll(() {
      initializeCache();
      initializeTranslator();
      initializeDatabase();
      initializeStorage();
      // Use menu to get product avator.
      Menu();
    });
  });
}
