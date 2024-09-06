import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/google_sheet/order_formatter.dart';
import 'package:possystem/ui/transit/google_sheet/order_setting_page.dart';
import 'package:possystem/ui/transit/transit_station.dart';

import '../../../mocks/mock_auth.dart';
import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_database.dart';
import '../../../mocks/mock_google_api.dart';
import '../../../services/auth_test.mocks.dart';
import '../../../test_helpers/order_setter.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - Google Sheet - Order', () {
    const cacheKey = 'exporter_order_google_sheet';
    const gsExporterScopes = [gs.SheetsApi.driveFileScope, gs.SheetsApi.spreadsheetsScope];

    Widget buildApp([CustomMockSheetsApi? sheetsApi]) {
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TransitStation(
              catalog: TransitCatalog.order,
              method: TransitMethod.googleSheet,
              exporter: GoogleSheetExporter(
                sheetsApi: sheetsApi,
                scopes: gsExporterScopes,
              ),
            ),
          ),
        ]),
      );
    }

    testWidgets('#preview', (tester) async {
      final order = OrderSetter.sample();
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);
      OrderSetter.setOrder(order);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.expand_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(Table), findsNWidgets(4));
    });

    testWidgets('#pick_range', (tester) async {
      OrderSetter.setMetrics([], countingAll: true);
      OrderSetter.setOrders([]);

      final init = DateTimeRange(
        start: DateTime(2023, DateTime.june, 10),
        end: DateTime(2023, DateTime.june, 11),
      );

      await tester.pumpWidget(MaterialApp(
        locale: LanguageSetting.instance.language.locale,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: [LanguageSetting.instance.language.locale],
        home: TransitStation(
          catalog: TransitCatalog.order,
          method: TransitMethod.googleSheet,
          range: init,
          exporter: GoogleSheetExporter(
            scopes: gsExporterScopes,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn.edit_range')));
      await tester.pumpAndSettle();

      // xx/01-xx/05
      await tester.tap(find.text('1').first);
      await tester.tap(find.text('5').first);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final expected = DateTimeRange(
        start: DateTime(2023, DateTime.june, 1),
        end: DateTime(2023, DateTime.june, 6),
      );

      expect(
        find.text(S.transitOrderMetaRange(expected.format('en'))),
        findsOneWidget,
      );
    });

    group('#export', () {
      testWidgets('create and overwrite', (tester) async {
        final order = OrderSetter.sample();
        OrderSetter.setMetrics([order], countingAll: true);
        OrderSetter.setOrders([order]);
        OrderSetter.setDetailedOrders([order]);

        final sheetsApi = getMockSheetsApi();
        final today = DateFormat('MMdd').format(DateTime.now());
        when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
        when(sheetsApi.spreadsheets.create(
          any,
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(gs.Spreadsheet(
              spreadsheetId: 'abc',
              sheets: OrderSheetType.values.map((e) {
                return gs.Sheet(
                  properties: gs.SheetProperties(
                    sheetId: e.index,
                    title: '$today ${S.transitModelName(e.name)}',
                  ),
                );
              }).toList(),
            )));
        when(sheetsApi.spreadsheets.values.batchUpdate(
          any,
          any,
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(gs.BatchUpdateValuesResponse()));

        await tester.pumpWidget(buildApp(sheetsApi));
        await tester.pumpAndSettle();
        await tester.tap(find.text(S.transitGSSpreadsheetExportEmptyLabel));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        final title = S.transitGSSpreadsheetOrderDefaultName;
        verify(cache.set(cacheKey, 'abc:true:$title'));

        final expected = [
          [
            OrderFormatter.orderHeaders,
            ...OrderFormatter.formatOrder(order),
          ],
          [
            OrderFormatter.orderDetailsAttrHeaders,
            ...OrderFormatter.formatOrderDetailsAttr(order),
          ],
          [
            OrderFormatter.orderDetailsProductHeaders,
            ...OrderFormatter.formatOrderDetailsProduct(order),
          ],
          [
            OrderFormatter.orderDetailsIngredientHeaders,
            ...OrderFormatter.formatOrderDetailsIngredient(order),
          ],
        ];
        verify(sheetsApi.spreadsheets.values.batchUpdate(
          argThat(predicate<gs.BatchUpdateValuesRequest?>((batch) {
            for (var e1 in expected) {
              final req = batch?.data?.removeAt(0);
              for (var e2 in e1) {
                final row = req?.values?.removeAt(0);
                for (var e3 in e2) {
                  final cell = row?.removeAt(0);
                  if (cell != e3) {
                    return false;
                  }
                }
              }
            }
            return true;
          })),
          any,
          $fields: anyNamed('\$fields'),
        )).called(1);
      });

      testWidgets('edit sheet name and append', (tester) async {
        final order = OrderSetter.sample();
        OrderSetter.setMetrics([order], countingAll: true);
        OrderSetter.setOrders([order]);
        OrderSetter.setDetailedOrders([order]);

        final sheetsApi = getMockSheetsApi();

        when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
        // exist spreadsheet
        when(cache.get(cacheKey)).thenReturn('id:true:name');
        when(cache.get('$cacheKey.order')).thenReturn('o title');
        when(cache.get('$cacheKey.orderDetailsAttr')).thenReturn('os title');
        when(cache.get('$cacheKey.orderDetailsProduct')).thenReturn('op title');
        when(cache.get('$cacheKey.orderDetailsIngredient')).thenReturn('oi title');
        when(cache.get('$cacheKey.order.required')).thenReturn(false);
        when(sheetsApi.spreadsheets.get(
          any,
          $fields: anyNamed('\$fields'),
          includeGridData: anyNamed('includeGridData'),
        )).thenAnswer((_) => Future.value(
              gs.Spreadsheet(
                  sheets: ['o', 'os', 'op', 'oi']
                      .map((e) => gs.Sheet(properties: gs.SheetProperties(title: '$e title', sheetId: 1)))
                      .toList()),
            ));
        when(sheetsApi.spreadsheets.values.append(
          any,
          any,
          any,
          includeValuesInResponse: anyNamed('includeValuesInResponse'),
          insertDataOption: anyNamed('insertDataOption'),
          valueInputOption: anyNamed('valueInputOption'),
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(gs.AppendValuesResponse()));

        await tester.pumpWidget(buildApp(sheetsApi));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('edit_sheets')));
        await tester.pumpAndSettle();
        // disable it
        await tester.tap(find.byKey(const Key('is_overwrite')));
        await tester.pumpAndSettle();
        // disable it
        await tester.tap(find.byKey(const Key('with_prefix')));
        await tester.pumpAndSettle();
        // save it
        await tester.tap(find.byKey(const Key('modal.save')));
        await tester.pumpAndSettle();

        verify(cache.set('$cacheKey.isOverwrite', false));
        verify(cache.set('$cacheKey.withPrefix', false));
        verify(cache.set('$cacheKey.order', 'o title'));
        verify(cache.set('$cacheKey.order.required', false));

        // export
        await tester.tap(find.text(S.transitGSSpreadsheetExportExistLabel));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
        await tester.pumpAndSettle();

        final expected = {
          'os title': OrderFormatter.formatOrderDetailsAttr(order),
          'op title': OrderFormatter.formatOrderDetailsProduct(order),
          'oi title': OrderFormatter.formatOrderDetailsIngredient(order),
        };
        for (final e in expected.entries) {
          verify(sheetsApi.spreadsheets.values.append(
            argThat(predicate<gs.ValueRange?>((vr) {
              if (vr?.range != "'${e.key}'") return false;
              for (var e1 in e.value) {
                final row = vr?.values?.removeAt(0);
                for (var e2 in e1) {
                  final cell = row?.removeAt(0);
                  if (cell != e2) {
                    return false;
                  }
                }
              }
              return true;
            })),
            any,
            "'${e.key}'",
            includeValuesInResponse: anyNamed('includeValuesInResponse'),
            insertDataOption: anyNamed('insertDataOption'),
            valueInputOption: anyNamed('valueInputOption'),
            $fields: anyNamed('\$fields'),
          ));
        }
      });
    });

    setUp(() async {
      await cache.reset();
      when(cache.get(any)).thenReturn(null);
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(MockUser()));
    });

    setUpAll(() {
      initializeCache();
      initializeTranslator();
      initializeDatabase();
      initializeAuth();
    });
  });
}
