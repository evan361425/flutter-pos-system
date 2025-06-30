// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/google_sheet/spreadsheet_dialog.dart';
import 'package:possystem/ui/transit/transit_station.dart';
import 'package:possystem/ui/transit/widgets.dart';

import '../../../mocks/mock_auth.dart';
import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_google_api.dart';
import '../../../mocks/mock_storage.dart';
import '../../../services/auth_test.mocks.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - Google Sheet - Import Basic', () {
    const gsExporterScopes = [gs.SheetsApi.driveFileScope, gs.SheetsApi.spreadsheetsScope];
    late TransitStateNotifier notifier;

    Widget buildApp([CustomMockSheetsApi? sheetsApi]) {
      notifier = TransitStateNotifier();
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TransitStation(
              catalog: TransitCatalog.importModel,
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
      await tester.tap(find.byKey(const Key('transit.model_picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.model_picker.menu')).first, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.model_export')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('transit.spreadsheet_confirm')));
      await tester.pump();
    }

    testWidgets('prepare spreadsheet failed', (tester) async {
      final sheetsApi = getMockSheetsApi();
      when(sheetsApi.spreadsheets.get(
        any,
        includeGridData: anyNamed('includeGridData'),
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet()));

      await tester.pumpWidget(buildApp(sheetsApi));
      await start(tester);

      expect(find.text(S.transitImportErrorGoogleSheetMissingTitle(FormattableModel.menu.l10nName)), findsOneWidget);
      expect(notifier.isProgressing, isFalse);
    });

    prepareSpreadsheet(CustomMockSheetsApi sheetsApi) {
      when(sheetsApi.spreadsheets.get(
        any,
        includeGridData: anyNamed('includeGridData'),
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet(sheets: [
            gs.Sheet(
              properties: gs.SheetProperties(
                sheetId: 1,
                title: FormattableModel.menu.l10nName,
              ),
            ),
          ])));
    }

    prepareSheetData(CustomMockSheetsApi sheetsApi, String title, List<List<Object?>>? data) {
      when(sheetsApi.spreadsheets.values.get(
        any,
        argThat(predicate<String>((n) {
          return n.startsWith("'$title'");
        })),
        majorDimension: anyNamed('majorDimension'),
        $fields: 'values',
      )).thenAnswer((_) => Future.value(gs.ValueRange(values: data)));
    }

    testWidgets('import spreadsheet but missing data', (tester) async {
      final sheetsApi = getMockSheetsApi();
      prepareSpreadsheet(sheetsApi);
      prepareSheetData(sheetsApi, FormattableModel.menu.l10nName, null);

      await tester.pumpWidget(buildApp(sheetsApi));
      await start(tester);
      await tester.pumpAndSettle();

      expect(find.text(S.transitImportErrorPreviewNotFound(FormattableModel.menu.l10nName)), findsOneWidget);
    });

    testWidgets('import spreadsheet success', (tester) async {
      final sheetsApi = getMockSheetsApi();
      prepareSpreadsheet(sheetsApi);
      prepareSheetData(sheetsApi, FormattableModel.menu.l10nName, [
        [], // header
        [],
      ]);

      await tester.pumpWidget(buildApp(sheetsApi));
      await start(tester);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('transit.import.confirm')), findsOneWidget);
    });

    setUp(() {
      Menu();
      Stock();
      Quantities();
      OrderAttributes();
      Replenisher();
      when(cache.get(importCacheKey)).thenReturn('1bCPUG2iS5xXqchWIa9Pq-TT4J-Bt9Pig6i-QqkOWEoE:true:old-name');
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(MockUser()));

      reset(storage);
      when(storage.add(any, any, any)).thenAnswer((_) => Future.value());
      when(storage.reset(any)).thenAnswer((_) => Future.value());
    });

    setUpAll(() {
      initializeStorage();
      initializeCache();
      initializeTranslator();
      initializeAuth();
    });
  });
}
