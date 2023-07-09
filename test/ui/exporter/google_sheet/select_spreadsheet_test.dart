// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/exporter_routes.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/sheet_namer.dart';

import '../../../mocks/mock_auth.dart';
import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_google_api.dart';
import '../../../services/auth_test.mocks.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Google Sheet Exporter Pick Spreadsheet', () {
    const eCacheKey = 'exporter_google_sheet';
    const iCacheKey = 'importer_google_sheet';
    const spreadsheetId = '1bCPUG2iS5xXqchWIa9Pq-TT4J-Bt9Pig6i-QqkOWEoE';
    const gsExporterScopes = [
      gs.SheetsApi.driveFileScope,
      gs.SheetsApi.spreadsheetsScope
    ];

    Widget buildApp([CustomMockSheetsApi? sheetsApi]) {
      return MaterialApp(
        home: ExporterStation(
          info: ExporterInfoType.basic,
          method: ExportMethod.googleSheet,
          exporter: GoogleSheetExporter(
            sheetsApi: sheetsApi,
            scopes: gsExporterScopes,
          ),
        ),
      );
    }

    Future<void> action(
      WidgetTester tester, [
      IconData icon = Icons.list_alt_sharp,
    ]) async {
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert_sharp));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(icon));
      await tester.pump();
    }

    DropdownButtonFormField<GoogleSheetProperties?> getSelector(
      String label,
    ) {
      return find
          .byKey(Key('gs_export.$label.sheet_selector'))
          .evaluate()
          .single
          .widget as DropdownButtonFormField<GoogleSheetProperties?>;
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

    testWidgets('exporter pick invalid and exist', (tester) async {
      when(cache.get(eCacheKey)).thenReturn('old-id:true:old-name');

      await tester.pumpWidget(buildApp());
      await action(tester);

      final editor = find.byKey(const Key('text_dialog.text'));
      final editorW = editor.evaluate().single.widget as TextFormField;
      expect(editorW.controller?.text, equals('old-id'));

      await tester.enterText(editor, 'QQ');
      await tester.tap(find.byKey(const Key('text_dialog.cancel')));
      await tester.pumpAndSettle();
      // not in dialog
      expect(find.byKey(const Key('text_dialog.cancel')), findsNothing);
    });

    testWidgets('exporter pick not exist', (tester) async {
      final sheetsApi = getMockSheetsApi();
      when(sheetsApi.spreadsheets.get(
        any,
        $fields: anyNamed('\$fields'),
        includeGridData: anyNamed('includeGridData'),
      )).thenAnswer((_) => Future.value(gs.Spreadsheet()));

      await tester.pumpWidget(buildApp(sheetsApi));
      await action(tester);

      await tester.enterText(
        find.byKey(const Key('text_dialog.text')),
        'https://docs.google.com/spreadsheets/d/1bCPUG2iS5xXqchWIa9Pq-TT4J-Bt9Pig6i-QqkOWEoE/edit#gid=307928354',
      );
      await tester.tap(find.byKey(const Key('text_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(find.text('找不到該表單，是否沒開放權限讀取？'), findsOneWidget);
    });

    testWidgets('exporter pick success', (tester) async {
      SheetNamerState? getNamer() {
        return tester
            .element(find.byKey(const Key('sheet_namer.menu')))
            .findAncestorStateOfType<SheetNamerState>();
      }

      final sheetsApi = getMockSheetsApi();
      mockPick(sheetsApi, spreadsheetId, 'some-sheet');

      await tester.pumpWidget(buildApp(sheetsApi));
      await tester.pumpAndSettle();
      expect(getNamer()!.widget.prop.hints, isNull);

      await action(tester);

      final editor = find.byKey(const Key('text_dialog.text'));
      final editorW = editor.evaluate().single.widget as TextFormField;
      expect(editorW.controller?.text, isEmpty);

      await tester.enterText(editor, spreadsheetId);
      await tester.tap(find.byKey(const Key('text_dialog.confirm')));
      await tester.pumpAndSettle();

      expect(getNamer()!.widget.prop.hints, equals(['some-sheet']));
      verify(cache.set(eCacheKey, '$spreadsheetId:false:title'));
    });

    testWidgets('export cancel old', (tester) async {
      clearInteractions(cache);
      when(cache.get(eCacheKey)).thenReturn('id:true:name');
      when(cache.get(eCacheKey + '.menu')).thenReturn('menu');

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('menu'), findsOneWidget);

      await action(tester, Icons.add_box_outlined);
      await tester.pumpAndSettle();

      // should not change
      expect(find.text('menu'), findsOneWidget);
      // should not cache
      verifyNever(cache.set(any, any));
    });

    testWidgets('importer pick new', (tester) async {
      when(cache.get(iCacheKey)).thenReturn('old-id:true:old-name');
      // test each situation when parsing
      when(cache.get(iCacheKey + '.menu')).thenReturn('menu title 1');
      when(cache.get(iCacheKey + '.stock')).thenReturn('stock');
      when(cache.get(iCacheKey + '.orderAttr')).thenReturn('orderAttr a');

      final sheetsApi = getMockSheetsApi();
      await tester.pumpWidget(buildApp(sheetsApi));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Tab, S.btnImport));
      await tester.pumpAndSettle();

      expect(getSelector('menu').initialValue?.title, equals('menu title'));
      expect(getSelector('menu').initialValue?.id, equals(1));
      expect(getSelector('stock').initialValue, isNull);
      expect(getSelector('orderAttr').initialValue, isNull);

      mockPick(sheetsApi, spreadsheetId, 'new-sheet');

      await action(tester);
      await tester.enterText(
        find.byKey(const Key('text_dialog.text')),
        '/spreadsheets/d/$spreadsheetId/',
      );
      await tester.tap(find.byKey(const Key('text_dialog.confirm')));
      await tester.pumpAndSettle();

      verify(cache.set(iCacheKey, '$spreadsheetId:false:title'));

      Future<void> tapSelector(String l) async {
        await tester.tap(find.byKey(Key('gs_export.$l.sheet_selector')));
        await tester.pumpAndSettle();
      }

      // both mene and stock (and others) exist new sheet options
      await tapSelector('menu');
      await tester.tap(find.text('new-sheet').last);
      await tester.pumpAndSettle();
      await tapSelector('stock');
      await tester.tap(find.text('new-sheet').last);
      await tester.pumpAndSettle();
    });

    setUp(() {
      Menu();
      Stock();
      Quantities();
      OrderAttributes();
      Replenisher();
      when(cache.get(any)).thenReturn(null);
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(MockUser()));
    });

    setUpAll(() {
      initializeTranslator();
      initializeCache();
      initializeAuth();
    });
  });
}
