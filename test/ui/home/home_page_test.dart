import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/app.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/app_themes.dart';
import 'package:possystem/models/analysis/analysis.dart';
import 'package:possystem/models/printer.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/breakpoint_mocker.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Home Page', () {
    for (final device in [Device.desktop, Device.landscape, Device.mobile]) {
      group(device.name, () {
        testWidgets('should navigate correctly', (tester) async {
          deviceAs(device, tester);
          // disable tutorial
          when(cache.get(
            argThat(predicate<String>((key) => key.startsWith('tutorial.'))),
          )).thenReturn(true);

          await tester.pumpWidget(MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: SettingsProvider.instance),
              ChangeNotifierProvider.value(value: Seller.instance),
              ChangeNotifierProvider.value(value: Menu()),
              ChangeNotifierProvider.value(value: Stock()..replaceItems({'i1': Ingredient(id: 'i1')})),
              ChangeNotifierProvider.value(value: Quantities()),
              ChangeNotifierProvider.value(value: OrderAttributes()),
              ChangeNotifierProvider.value(value: Analysis()),
              ChangeNotifierProvider.value(value: Cart()),
              ChangeNotifierProvider.value(value: Cashier()),
              ChangeNotifierProvider.value(value: Printers()),
            ],
            child: MaterialApp.router(
              routerConfig: GoRouter(
                navigatorKey: Routes.rootNavigatorKey,
                observers: [App.routeObserver],
                initialLocation: device == Device.mobile ? '${Routes.base}/_' : '${Routes.base}/_/menu',
                routes: Routes.getDesiredRoute(device.width / tester.view.devicePixelRatio).routes,
              ),
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
            ),
          ));

          Future<void> navAndCheck(
            String key,
            String check, {
            bool drag = false,
            bool pop = true,
            bool openMenu = true,
            Device? only,
            IconData? icon,
          }) async {
            if (only != null && device != only) {
              return;
            }

            if (device == Device.landscape && openMenu) {
              await tester.tap(find.byIcon(Icons.menu));
              await tester.pumpAndSettle();
            }

            if (drag) {
              await tester.dragFrom(const Offset(400, 400), const Offset(0, -200));
              await tester.pumpAndSettle();
            }

            if (device == Device.desktop && icon != null) {
              await tester.tap(find.byIcon(icon));
            } else {
              await tester.tap(find.byKey(Key(key)));
            }
            await tester.pumpAndSettle();

            expect(find.byKey(Key(check)), findsOneWidget);

            if (device == Device.mobile && pop) {
              await tester.tap(find.byKey(const Key('pop')));
              await tester.pumpAndSettle();
            }
          }

          if (device == Device.desktop) {
            await tester.tap(find.byIcon(Icons.menu));
            await tester.pumpAndSettle();
          }

          await navAndCheck('more_header.products', 'menu_page', only: Device.mobile);
          await navAndCheck('more_header.printers', 'printers_page', only: Device.mobile);
          await navAndCheck('more_header.order_attrs', 'order_attributes_page', only: Device.mobile);
          await navAndCheck('home.debug', 'debug.list', icon: Icons.bug_report_outlined);
          await navAndCheck('home.menu', 'menu_page', icon: Icons.collections_outlined);
          await navAndCheck('home.printers', 'printers_page', drag: true, icon: Icons.print_outlined);
          await navAndCheck('home.transit', 'transit.google_sheet', icon: Icons.local_shipping_outlined);
          await navAndCheck('home.stockQuantities', 'quantities_page', drag: true, icon: Icons.exposure_outlined);
          await navAndCheck('home.orderAttributes', 'order_attributes_page', icon: Icons.assignment_ind_outlined);
          await navAndCheck('home.elf', 'elf_page', icon: Icons.lightbulb_outlined);
          await navAndCheck('home.settings', 'feature.theme', drag: true, icon: Icons.settings_outlined);

          if (device == Device.desktop) {
            await tester.tap(find.byIcon(Icons.close));
            await tester.pumpAndSettle();
          }

          await navAndCheck('home.stock', 'stock.replenisher', pop: false, icon: Icons.inventory_2_outlined);
          await navAndCheck('home.cashier', 'cashier.changer', pop: false, icon: Icons.monetization_on_outlined);
          await navAndCheck('home.analysis', 'anal.history', pop: false, icon: Icons.analytics_outlined);

          await navAndCheck('home.order', 'order.more', openMenu: false);
        });
      });
    }

    group('example menu', () {
      setUp(() {
        when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
      });

      Widget buildApp(WidgetTester tester, {Device device = Device.mobile}) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: SettingsProvider.instance),
            ChangeNotifierProvider.value(value: Menu()),
            ChangeNotifierProvider.value(value: Stock()),
            ChangeNotifierProvider.value(value: Quantities()),
            ChangeNotifierProvider.value(value: OrderAttributes()),
            ChangeNotifierProvider.value(value: Analysis()),
            ChangeNotifierProvider.value(value: Printers()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              navigatorKey: Routes.rootNavigatorKey,
              observers: [App.routeObserver],
              initialLocation: device == Device.mobile ? '${Routes.base}/_' : '${Routes.base}/_/menu',
              routes: Routes.getDesiredRoute(device.width / tester.view.devicePixelRatio).routes,
            ),
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
          ),
        );
      }

      Future<void> startTutorial(WidgetTester tester) async {
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 5));
      }

      Future<void> goNext(WidgetTester tester) async {
        await tester.tapAt(Offset.zero);
        await tester.pump(const Duration(milliseconds: 5));
        await tester.pump(const Duration(milliseconds: 5));
      }

      for (final device in [Device.desktop, Device.landscape, Device.mobile]) {
        group(device.name, () {
          testWidgets('setup', (tester) async {
            deviceAs(device, tester);
            await tester.pumpWidget(buildApp(tester, device: device));
            expect(Menu.instance.isEmpty, isTrue);
            expect(OrderAttributes.instance.isEmpty, isTrue);

            await startTutorial(tester);
            expect(find.text(S.menuTutorialTitle), findsOneWidget);

            await goNext(tester);
            expect(find.text(S.orderAttributeTutorialTitle), findsOneWidget);
            expect(Menu.instance.isNotEmpty, isTrue);
            verify(cache.set('tutorial.home.menu', true));

            await goNext(tester);

            expect(find.text(S.orderTutorialTitle), findsOneWidget);
            expect(OrderAttributes.instance.isNotEmpty, isTrue);
            verify(cache.set('tutorial.home.order_attr', true));
          });
        });
      }

      testWidgets('disabled', (tester) async {
        await tester.pumpWidget(buildApp(tester));

        await startTutorial(tester);
        await tester.tap(find.text(S.menuTutorialCreateExample));
        await goNext(tester);

        expect(find.text(S.orderAttributeTutorialContent), findsOneWidget);
        expect(Menu.instance.isNotEmpty, isFalse);
        verify(cache.set('tutorial.home.menu', true));
      });
    });

    setUp(() {
      reset(auth);
      reset(cache);
      reset(database);

      // setup currency
      when(cache.get(any)).thenReturn(null);
      CurrencySetting.instance.initialize();

      // setup auth
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(null));

      // setup seller
      when(database.query(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([
            {'totalPrice': 20, 'count': 10},
          ]));
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
    });

    setUpAll(() {
      Tutorial.debug = true;
      initializeAuth();
      initializeCache();
      initializeStorage();
      initializeDatabase();
      initializeTranslator();
    });
  });
}
