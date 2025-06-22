import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:mockito/mockito.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/formatter/order_formatter.dart';
import 'package:possystem/ui/transit/transit_station.dart';
import 'package:possystem/ui/transit/widgets.dart';

import '../../../mocks/mock_auth.dart';
import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_database.dart';
import '../../../mocks/mock_google_api.dart';
import '../../../services/auth_test.mocks.dart';
import '../../../test_helpers/order_setter.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - Google Sheet - Order', () {
    const gsExporterScopes = [gs.SheetsApi.driveFileScope, gs.SheetsApi.spreadsheetsScope];
    late TransitStateNotifier notifier;
    late OrderObject order;

    Widget buildApp([CustomMockSheetsApi? sheetsApi]) {
      notifier = TransitStateNotifier();
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TransitStation(
              catalog: TransitCatalog.exportOrder,
              method: TransitMethod.googleSheet,
              notifier: notifier,
              exporter: GoogleSheetExporter(
                sheetsApi: sheetsApi,
                scopes: gsExporterScopes,
              ),
            ),
          ),
        ]),
      );
    }

    testWidgets('select spreadsheet failed', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.order_export')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('transit.spreadsheet_cancel')));
      await tester.pump();

      expect(notifier.isProgressing, isFalse);
    });

    Future<void> start(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.order_export')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('transit.spreadsheet_confirm')));
      await tester.pump();
    }

    testWidgets('prepare spreadsheet failed', (tester) async {
      final sheetsApi = getMockSheetsApi();
      when(sheetsApi.spreadsheets.create(
        any,
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet()));

      await tester.pumpWidget(buildApp(sheetsApi));
      await start(tester);

      expect(find.text(S.transitGoogleSheetErrorCreateTitle), findsOneWidget);
      expect(notifier.isProgressing, isFalse);
    });

    void prepareSpreadsheet(CustomMockSheetsApi sheetsApi) {
      when(cache.get('exporter_order_meta.withPrefix')).thenReturn(false);
      when(sheetsApi.spreadsheets.create(
        any,
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet(
            spreadsheetId: 'abc',
            sheets: FormattableOrder.values.map((e) {
              return gs.Sheet(
                properties: gs.SheetProperties(
                  sheetId: e.index,
                  title: e.l10nName,
                ),
              );
            }).toList(),
          )));
    }

    testWidgets('export orders to spreadsheet and overwrite', (tester) async {
      final sheetsApi = getMockSheetsApi();
      prepareSpreadsheet(sheetsApi);
      when(sheetsApi.spreadsheets.values.batchUpdate(
        any,
        any,
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.BatchUpdateValuesResponse()));

      await tester.pumpWidget(buildApp(sheetsApi));
      await start(tester);

      final expected = [
        [
          OrderFormatter.basicHeaders,
          ...OrderFormatter.formatBasic(order),
        ],
        [
          OrderFormatter.attrHeaders,
          ...OrderFormatter.formatAttr(order),
        ],
        [
          OrderFormatter.productHeaders,
          ...OrderFormatter.formatProduct(order),
        ],
        [
          OrderFormatter.ingredientHeaders,
          ...OrderFormatter.formatIngredient(order),
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
                final val = e3 is CellData ? e3.value : e3;
                if (cell != val) {
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

    testWidgets('export orders to spreadsheet and append it', (tester) async {
      when(cache.get('exporter_order_meta.isOverwrite')).thenReturn(false);
      final sheetsApi = getMockSheetsApi();
      prepareSpreadsheet(sheetsApi);
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
      await start(tester);

      final expected = {
        FormattableOrder.basic.l10nName: OrderFormatter.formatBasic(order),
        FormattableOrder.attr.l10nName: OrderFormatter.formatAttr(order),
        FormattableOrder.product.l10nName: OrderFormatter.formatProduct(order),
        FormattableOrder.ingredient.l10nName: OrderFormatter.formatIngredient(order),
      };
      for (final e in expected.entries) {
        verify(sheetsApi.spreadsheets.values.append(
          argThat(predicate<gs.ValueRange?>((vr) {
            if (vr?.range != "'${e.key}'") return false;
            for (var e1 in e.value) {
              final row = vr?.values?.removeAt(0);
              for (var e2 in e1) {
                final cell = row?.removeAt(0);
                if (cell != e2.value) {
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

    setUp(() async {
      reset(cache);
      reset(database);
      order = OrderSetter.sample();
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);
      OrderSetter.setDetailedOrders([order]);
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
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
