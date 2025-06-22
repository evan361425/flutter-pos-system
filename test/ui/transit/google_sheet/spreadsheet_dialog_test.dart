// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:mockito/mockito.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/google_sheet_exporter.dart';
import 'package:possystem/ui/transit/google_sheet/spreadsheet_dialog.dart';
import 'package:possystem/ui/transit/widgets.dart';

import '../../../mocks/mock_auth.dart';
import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_google_api.dart';
import '../../../services/auth_test.mocks.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - Google Sheet - Spreadsheet Dialog', () {
    const gsExporterScopes = [gs.SheetsApi.driveFileScope, gs.SheetsApi.spreadsheetsScope];
    late GoogleSheetExporter exporter;
    bool shouldPrepare = false;
    GoogleSpreadsheet? spreadsheet;

    Future<GoogleSpreadsheet?> prepare(BuildContext context, GoogleSpreadsheet sheet) => prepareSpreadsheet(
          context: context,
          exporter: exporter,
          stateNotifier: TransitStateNotifier(),
          defaultName: 'some name',
          cacheKey: exportCacheKey,
          sheets: ['sheet1', 'sheet2'],
          spreadsheet: sheet,
        );

    Widget buildApp([CustomMockSheetsApi? sheetsApi]) {
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Builder(builder: (context) {
                exporter = GoogleSheetExporter(sheetsApi: sheetsApi, scopes: gsExporterScopes);
                return TextButton(
                  key: const Key('test_show_dialog'),
                  onPressed: () async {
                    final sheet = await SpreadsheetDialog.show(
                      context,
                      exporter: GoogleSheetExporter(sheetsApi: sheetsApi, scopes: gsExporterScopes),
                      cacheKey: exportCacheKey,
                      allowCreateNew: true,
                      fallbackCacheKey: importCacheKey,
                    );
                    if (shouldPrepare && sheet != null) {
                      spreadsheet = await prepare(context, sheet);
                    }
                  },
                  child: const Text('show'),
                );
              }),
            ),
          ),
        ]),
      );
    }

    Future<void> action(
      WidgetTester tester, [
      IconData icon = Icons.file_open_outlined,
    ]) async {
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('test_show_dialog')));
      await tester.pumpAndSettle();
    }

    void mockPick(CustomMockSheetsApi sheetsApi, String id, String sheet) {
      final sheet1 = gs.SheetProperties(title: sheet, sheetId: 1);

      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
      when(sheetsApi.mockSpreadsheets.get(
        argThat(equals(id)),
        includeGridData: anyNamed('includeGridData'),
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet(
            properties: gs.SpreadsheetProperties(title: 'title'),
            sheets: [gs.Sheet(properties: sheet1)],
          )));
    }

    testWidgets('invalid id', (tester) async {
      when(cache.get(exportCacheKey)).thenReturn('old-id:true:old-name');

      await tester.pumpWidget(buildApp());
      await action(tester);

      final editor = find.byKey(const Key('transit.spreadsheet_editor'));
      final editorW = editor.evaluate().single.widget as TextFormField;
      expect(editorW.controller?.text, equals('old-id'));

      await tester.enterText(editor, 'QQ');
      await tester.tap(find.byKey(const Key('transit.spreadsheet_confirm')));
      await tester.pump();
      expect(find.text(S.transitGoogleSheetErrorIdInvalid), findsOneWidget);
    });

    testWidgets('not found', (tester) async {
      when(cache.get(importCacheKey)).thenReturn('old-id:true:old-name');
      final sheetsApi = getMockSheetsApi();
      when(sheetsApi.spreadsheets.get(
        any,
        $fields: anyNamed('\$fields'),
        includeGridData: anyNamed('includeGridData'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet()));

      await tester.pumpWidget(buildApp(sheetsApi));
      await action(tester);

      await tester.enterText(
        find.byKey(const Key('transit.spreadsheet_editor')),
        'https://docs.google.com/spreadsheets/d/1bCPUG2iS5xXqchWIa9Pq-TT4J-Bt9Pig6i-QqkOWEoE/edit#gid=307928354',
      );
      await tester.tap(find.byKey(const Key('transit.spreadsheet_confirm')));
      await tester.pumpAndSettle();

      expect(
        find.text('${S.transitGoogleSheetErrorIdNotFound}\n${S.transitGoogleSheetErrorIdNotFoundHelper}'),
        findsOneWidget,
      );
    });

    testWidgets('pick success', (tester) async {
      when(cache.get(importCacheKey)).thenReturn('old-id:true:old-name');
      const spreadsheetId = '1bCPUG2iS5xXqchWIa9Pq-TT4J-Bt9Pig6i-QqkOWEoE';

      final sheetsApi = getMockSheetsApi();
      mockPick(sheetsApi, spreadsheetId, 'some-sheet');

      await tester.pumpWidget(buildApp(sheetsApi));
      await action(tester);

      final editor = find.byKey(const Key('transit.spreadsheet_editor'));
      final editorW = editor.evaluate().single.widget as TextFormField;
      expect(editorW.controller?.text, equals('old-id'));

      await tester.enterText(editor, spreadsheetId);
      await tester.tap(find.byKey(const Key('transit.spreadsheet_confirm')));
      await tester.pumpAndSettle();

      verify(cache.set(exportCacheKey, '$spreadsheetId:false:title'));
    });

    testWidgets('create failed', (tester) async {
      shouldPrepare = true;

      final sheetsApi = getMockSheetsApi();
      when(sheetsApi.spreadsheets.create(
        argThat(predicate<gs.Spreadsheet>((e) {
          return e.sheets?.length == 2 && e.properties?.title == 'some name';
        })),
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet()));

      await tester.pumpWidget(buildApp(sheetsApi));
      await action(tester);
      await tester.tap(find.text(S.transitGoogleSheetDialogSelectExist));
      await tester.pump();
      await tester.tap(find.text(S.transitGoogleSheetDialogCreate));
      await tester.pump();
      await tester.tap(find.byKey(const Key('transit.spreadsheet_confirm')));
      await tester.pumpAndSettle();

      expect(find.text(S.transitGoogleSheetErrorCreateTitle), findsOneWidget);
      expect(spreadsheet, isNull);
    });

    testWidgets('create success', (tester) async {
      shouldPrepare = true;

      final sheetsApi = getMockSheetsApi();
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
      when(sheetsApi.spreadsheets.create(
        any,
        $fields: anyNamed('\$fields'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet(spreadsheetId: 'abc')));

      await tester.pumpWidget(buildApp(sheetsApi));
      await action(tester);
      await tester.tap(find.byKey(const Key('transit.spreadsheet_confirm')));
      await tester.pumpAndSettle();

      verify(cache.set(exportCacheKey, 'abc:true:some name'));
      expect(spreadsheet, isNotNull);
    });

    gs.Sheet createSheet(String title, int id) {
      return gs.Sheet(properties: gs.SheetProperties(title: title, sheetId: id));
    }

    testWidgets('prepare spreadsheet and no missing sheets remotely', (tester) async {
      final sheetsApi = getMockSheetsApi();
      when(sheetsApi.spreadsheets.get(
        any,
        $fields: anyNamed('\$fields'),
        includeGridData: anyNamed('includeGridData'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet(sheets: [
            createSheet('sheet1', 1),
            createSheet('sheet2', 2),
          ])));
      exporter = GoogleSheetExporter(sheetsApi: sheetsApi, scopes: gsExporterScopes);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => spreadsheet = await prepare(
              context,
              GoogleSpreadsheet(id: 'id', name: 'name', sheets: []),
            ),
            child: const Text('test'),
          ),
        ),
      ));
      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();

      expect(spreadsheet, isNotNull);
      expect(spreadsheet!.sheets.map((e) => e.title).join(','), equals('sheet1,sheet2'));
    });

    testWidgets('prepare spreadsheet but add failed', (tester) async {
      final sheetsApi = getMockSheetsApi();
      when(sheetsApi.spreadsheets.get(
        any,
        $fields: anyNamed('\$fields'),
        includeGridData: anyNamed('includeGridData'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet()));
      when(sheetsApi.spreadsheets.batchUpdate(
        argThat(predicate<gs.BatchUpdateSpreadsheetRequest>((e) {
          return e.requests?.length == 2 && e.requests?.first.addSheet?.properties?.title == 'sheet1';
        })),
        'id',
      )).thenAnswer((_) => Future.value(gs.BatchUpdateSpreadsheetResponse()));
      exporter = GoogleSheetExporter(sheetsApi: sheetsApi, scopes: gsExporterScopes);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => spreadsheet = await prepare(
                context,
                GoogleSpreadsheet(id: 'id', name: 'name', sheets: []),
              ),
              child: const Text('test'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();

      expect(spreadsheet, isNull);
      expect(find.text(S.transitGoogleSheetErrorFulfillTitle), findsOneWidget);
    });

    testWidgets('prepare spreadsheet and add successfully', (tester) async {
      final sheetsApi = getMockSheetsApi();
      when(sheetsApi.spreadsheets.get(
        any,
        $fields: anyNamed('\$fields'),
        includeGridData: anyNamed('includeGridData'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet()));
      when(sheetsApi.spreadsheets.batchUpdate(any, any)).thenAnswer(
        (_) => Future.value(gs.BatchUpdateSpreadsheetResponse(
          replies: [gs.Response(addSheet: gs.AddSheetResponse(properties: createSheet('title', 1).properties))],
        )),
      );
      exporter = GoogleSheetExporter(sheetsApi: sheetsApi, scopes: gsExporterScopes);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => spreadsheet = await prepare(
              context,
              GoogleSpreadsheet(id: 'id', name: 'name', sheets: []),
            ),
            child: const Text('test'),
          ),
        ),
      ));
      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();

      expect(spreadsheet, isNotNull);
      expect(spreadsheet!.sheets.map((e) => e.title).join(','), equals('title'));
    });

    setUp(() {
      shouldPrepare = false;
      spreadsheet = null;
      clearInteractions(cache);
      when(cache.get(any)).thenReturn(null);
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(MockUser()));
    });

    setUpAll(() {
      initializeTranslator();
      initializeCache();
      initializeAuth();
    });
  });

  test('GoogleSheetProperties hash code', () {
    final a = GoogleSheetProperties(1, 'title');
    final b = GoogleSheetProperties(1, 'title');
    final c = GoogleSheetProperties(1, 'title2');
    final d = GoogleSheetProperties(2, 'title');

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a, isNot(equals(c)));
    expect(a.hashCode, isNot(equals(c.hashCode)));
    expect(a, isNot(equals(d)));
    expect(a.hashCode, isNot(equals(d.hashCode)));
  });
}
