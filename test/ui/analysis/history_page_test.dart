import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/history_page.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart' show CalendarFormat;

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../test_helpers/breakpoint_mocker.dart';
import '../../test_helpers/order_setter.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('History Page', () {
    Widget buildApp({themeMode = ThemeMode.light}) {
      // setup currency and cashier relation
      when(cache.get(any)).thenReturn(null);
      // disable tutorial
      when(cache.get(
        argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
      )).thenReturn(true);
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Seller.instance),
          ChangeNotifierProvider.value(value: Printers()),
        ],
        builder: (_, __) => MaterialApp.router(
          themeMode: themeMode,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
            GoRoute(
              path: '/',
              builder: (_, __) {
                return const HistoryPage();
              },
            ),
            ...Routes.getDesiredRoute(0).routes,
          ]),
        ),
      );
    }

    void mockGetCountPerDay(List<Map<String, Object?>> count) {
      when(database.query(
        any,
        columns: argThat(
          equals(['day', 'COUNT(price) count']),
          named: 'columns',
        ),
        groupBy: argThat(equals('day'), named: 'groupBy'),
        orderBy: anyNamed('orderBy'),
        escapeTable: false,
      )).thenAnswer((_) => Future.value(count));
    }

    testWidgets('select date and show order list in mobile', (tester) async {
      final now = DateTime.now();
      final nowD = DateTime(now.year, now.month, now.day);
      final nowS = (nowD.millisecondsSinceEpoch -
              DateTime(now.year, now.month).subtract(const Duration(days: 7)).millisecondsSinceEpoch) ~/
          86400000; // get days

      final o1 = OrderSetter.sample(id: 1);
      final o2 = OrderSetter.sample(id: 2);
      OrderSetter.setOrders([o1, o2]);
      OrderSetter.setMetrics([o1, o2]);
      mockGetCountPerDay([
        {'day': nowS, 'count': 100},
        {'day': nowS - 1, 'count': 50},
      ]);

      deviceAs(Device.mobile, tester);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);

      // select date
      await tester.tap(find.text(now.day.toString()));
      await tester.pumpAndSettle();

      // find by OrderTile key
      expect(find.byKey(const Key('history.order.1')), findsOneWidget);
      expect(find.byKey(const Key('history.order.2')), findsOneWidget);

      // should reload if seller updated
      Seller.instance.notifyListeners();
      await tester.pumpAndSettle();

      verify(database.query(
        Seller.orderTable,
        columns: argThat(contains('COUNT(*) count'), named: 'columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(2);
    });

    testWidgets('load count when page changed in landscape', (tester) async {
      final now = DateTime.now();
      final nowD = DateTime(now.year, now.month, now.day);
      final nowS = (nowD.millisecondsSinceEpoch -
              DateTime(now.year, now.month).subtract(const Duration(days: 7)).millisecondsSinceEpoch) ~/
          86400000; // get days
      OrderSetter.setOrders([]);
      OrderSetter.setMetrics([]);
      mockGetCountPerDay([
        {'day': nowS, 'count': 50},
        // last month
        {'day': nowS - now.day - 7, 'count': 60},
      ]);

      deviceAs(Device.landscape, tester);

      await tester.pumpWidget(buildApp(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      expect(find.text('50'), findsOneWidget);
      expect(find.text('60'), findsNothing);

      // go to prev page(month)
      mockGetCountPerDay([]);
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('50'), now.day < now.weekday ? findsOneWidget : findsNothing);
      expect(find.text('60'), findsOneWidget);

      // change format
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));

      await tester.tap(find.text(S.twoWeeks));
      await tester.pumpAndSettle();

      verify(cache.set('history.calendar_format', CalendarFormat.twoWeeks.index));
    });

    testWidgets('should navigate to exporter', (tester) async {
      mockGetCountPerDay([]);
      OrderSetter.setOrders([]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('history.export')));
      await tester.pumpAndSettle();
      // dropdown have multiple child for items
      await tester.tap(find.text(S.transitMethodName('plainText')).last);
      await tester.pumpAndSettle();

      expect(find.text(S.transitMethodName('plainText')), findsOneWidget);
    });

    setUp(() {
      reset(cache);
    });

    setUpAll(() {
      initializeCache();
      initializeDatabase();
      initializeTranslator();
    });
  });
}
