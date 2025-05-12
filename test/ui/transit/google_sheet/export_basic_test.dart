// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/launcher.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/transit_station.dart';
import 'package:possystem/ui/transit/widgets.dart';

import '../../../mocks/mock_auth.dart';
import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_google_api.dart';
import '../../../services/auth_test.mocks.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - Google Sheet - Export Basic', () {
    const gsExporterScopes = [gs.SheetsApi.driveFileScope, gs.SheetsApi.spreadsheetsScope];
    late TransitStateNotifier notifier;

    Widget buildApp([CustomMockSheetsApi? sheetsApi]) {
      notifier = TransitStateNotifier();
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TransitStation(
              catalog: TransitCatalog.exportModel,
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
      await tester.tap(find.byKey(const Key('transit.model_export')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('transit.spreadsheet_cancel')));
      await tester.pump();

      expect(notifier.isProgressing, isFalse);
    });

    Future<void> start(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.model_export')));
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

    testWidgets('update spreadsheet success', (tester) async {
      final i1 = Ingredient(id: 'i1', name: 'i1');
      Stock.instance.replaceItems({'i1': i1});

      final q1 = Quantity(id: 'q1', name: 'q1');
      Quantities.instance.replaceItems({'q1': q1});

      final pQ1 = ProductQuantity(id: 'pQ1', quantity: q1);
      final pI1 = ProductIngredient(id: 'pI1', ingredient: i1, quantities: {'pQ1': pQ1})..prepareItem();
      final p1 = Product(id: 'p1', name: 'p1', ingredients: {'pI1': pI1})..prepareItem();
      final c1 = Catalog(id: 'c1', name: 'c1', products: {'p1': p1})..prepareItem();
      Menu.instance.replaceItems({'c1': c1});

      final sheetsApi = getMockSheetsApi();
      when(sheetsApi.spreadsheets.create(
        any,
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(
            gs.Spreadsheet(spreadsheetId: 'id', sheets: [
              gs.Sheet(properties: gs.SheetProperties(title: FormattableModel.menu.l10nName, sheetId: 1)),
            ]),
          ));
      when(sheetsApi.spreadsheets.batchUpdate(
        any,
        any,
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.BatchUpdateSpreadsheetResponse()));

      await tester.pumpWidget(buildApp(sheetsApi));
      await start(tester);

      verify(sheetsApi.spreadsheets.batchUpdate(
        argThat(predicate((e) {
          return e is gs.BatchUpdateSpreadsheetRequest && e.requests?.length == 1;
        })),
        any,
        $fields: anyNamed('\$fields'),
      ));

      expect(find.text(S.transitExportBasicSuccessGoogleSheet), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.transitExportBasicSuccessActionGoogleSheet));
      await tester.pumpAndSettle();

      expect(Launcher.lastUrl, equals('https://docs.google.com/spreadsheets/d/id/edit'));
      expect(notifier.isProgressing, isFalse);
    });

    setUp(() {
      Menu();
      Stock();
      Quantities();
      OrderAttributes();
      Replenisher();

      clearInteractions(cache);
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(MockUser()));
    });

    setUpAll(() {
      initializeCache();
      initializeTranslator();
      initializeAuth();
    });
  });
}
