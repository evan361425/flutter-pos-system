import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/transit/transit_page.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_cache.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Transit Page', () {
    testWidgets('nav', (tester) async {
      const keys = ['transit.google_sheet', 'transit.plain_text'];

      when(cache.get(any)).thenReturn(null);

      await tester.pumpWidget(MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: TransitPage()),
          ),
          ...Routes.getDesiredRoute(0).routes,
        ]),
      ));

      for (var key in keys) {
        await tester.tap(find.byKey(Key(key)));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.byKey(const Key('pop')).last);
        await tester.pumpAndSettle();
      }

      // move to basic
      await tester.timedDragFrom(
        const Offset(300, 300),
        const Offset(-200, 0),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();

      for (var key in keys) {
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('transit.basic_tab')), findsOneWidget);

        await tester.tap(find.byKey(const Key('pop')));
        await tester.pumpAndSettle();
      }
    });

    setUp(() {
      Menu();
      Stock();
      Quantities();
      Replenisher();
      OrderAttributes();
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(null));
    });

    setUpAll(() {
      initializeTranslator();
      initializeCache();
      initializeAuth();
    });
  });
}
