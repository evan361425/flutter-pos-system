// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/launcher.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/transit_station.dart';

import '../../../mocks/mock_auth.dart';
import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_google_api.dart';
import '../../../services/auth_test.mocks.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - Google Sheet - Basic', () {
    const eCacheKey = 'exporter_google_sheet';
    const iCacheKey = 'importer_google_sheet';
    const gsExporterScopes = [gs.SheetsApi.driveFileScope, gs.SheetsApi.spreadsheetsScope];

    Widget buildApp([CustomMockSheetsApi? sheetsApi]) {
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TransitStation(
              catalog: TransitCatalog.model,
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

    void prepareData() {
      final i1 = Ingredient(id: 'i1', name: 'i1');
      final i2 = Ingredient(id: 'i2', name: 'i2', currentAmount: 10);
      Stock.instance.replaceItems({'i1': i1, 'i2': i2});

      final q1 = Quantity(id: 'q1', name: 'q1');
      Quantities.instance.replaceItems({'q1': q1});

      final pQ1 = ProductQuantity(id: 'pQ1', quantity: q1);
      final pI1 = ProductIngredient(id: 'pI1', ingredient: i1, quantities: {'pQ1': pQ1});
      pI1.prepareItem();
      final p1 = Product(id: 'p1', name: 'p1', ingredients: {'pI1': pI1});
      p1.prepareItem();
      final c1 = Catalog(id: 'c1', name: 'c1', products: {'p1': p1});
      c1.prepareItem();
      Menu.instance.replaceItems({'c1': c1});

      final r1 = Replenishment(id: 'r1', name: 'r1', data: {'i1': 1});
      Replenisher.instance.replaceItems({'r1': r1});

      final o1 = OrderAttributeOption(id: 'o1', name: 'o1', modeValue: 1);
      final o2 = OrderAttributeOption(id: 'o2', name: 'o2', isDefault: true);
      final cs1 = OrderAttribute(id: 'cs1', name: 'cs1', options: {
        'o1': o1,
        'o2': o2,
      });
      cs1.prepareItem();
      OrderAttributes.instance.replaceItems({'cs1': cs1});
    }

    testWidgets('#preview', (tester) async {
      Stock.instance.replaceItems({'i1': Ingredient(id: 'i1', name: 'i1')});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      CheckboxListTile checkbox(String key) =>
          find.byKey(Key('sheet_namer.$key')).evaluate().single.widget as CheckboxListTile;
      bool isChecked(String key) => checkbox(key).value == true;

      // only non-empty will check default
      const sheets = ['menu', 'stock', 'quantities', 'replenisher', 'orderAttr'];
      expect(sheets.where(isChecked).length, equals(1));

      checkbox('menu').onChanged!(true);
      await tester.pumpAndSettle();
      expect(sheets.where(isChecked).length, equals(2));

      prepareData();

      Future<void> checkPreview(String key, Iterable<String> values) async {
        await tester.tap(find.byKey(Key('sheet_namer.$key.more')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn.custom')));
        await tester.pumpAndSettle();
        for (var value in values) {
          expect(find.text(value), findsOneWidget);
        }
        await tester.tap(find.byKey(const Key('pop')).last);
        await tester.pumpAndSettle();
      }

      await checkPreview('stock', ['i1']);
      await checkPreview('quantities', ['q1']);
      await checkPreview('menu', ['c1', 'p1', '- i1,0\n  + q1,0,0,0']);
      await checkPreview('replenisher', ['r1', '- i1,1']);
      await checkPreview('orderAttr', ['cs1', '- o1,false,1\n- o2,true,']);
    });

    group('#export', () {
      Future<void> tapBtn(
        WidgetTester tester, {
        bool selected = true,
      }) async {
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(selected ? S.transitGSSpreadsheetExportExistLabel : S.transitGSSpreadsheetExportEmptyLabel).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
        await tester.pumpAndSettle();
      }

      testWidgets('empty checked', (tester) async {
        final notifier = ValueNotifier<String>('');
        Stock.instance.replaceItems({});
        await tester.pumpWidget(
          MaterialApp(
            home: TransitStation(
              catalog: TransitCatalog.model,
              method: TransitMethod.googleSheet,
              notifier: notifier,
              exporter: GoogleSheetExporter(),
            ),
          ),
        );
        await tapBtn(tester);
        // no repo checked, but still run the notifier process
        expect(notifier.value, equals('_finish'));
      });

      testWidgets('repeat name', (tester) async {
        prepareData();
        when(cache.get(eCacheKey + '.menu')).thenReturn('title');
        await tester.pumpWidget(buildApp());
        await tapBtn(tester);
        expect(find.text(S.transitGSErrorSheetRepeat), findsOneWidget);
      });

      testWidgets('spreadsheet create failed', (tester) async {
        final sheetsApi = getMockSheetsApi();
        when(cache.get(eCacheKey)).thenReturn(null);
        when(sheetsApi.spreadsheets.create(
          argThat(predicate<gs.Spreadsheet>((e) {
            return e.sheets?.length == 1 && e.sheets?.first.properties?.title == 'title';
          })),
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(gs.Spreadsheet()));

        await tester.pumpWidget(buildApp(sheetsApi));
        await tapBtn(tester, selected: false);

        expect(find.text(S.transitGSErrorCreateSpreadsheet), findsOneWidget);
      });

      testWidgets('spreadsheet create success', (tester) async {
        final sheetsApi = getMockSheetsApi();
        when(cache.get(eCacheKey)).thenReturn(null);
        when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
        when(sheetsApi.spreadsheets.create(
          any,
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(
              gs.Spreadsheet(spreadsheetId: 'abc'),
            ));

        await tester.pumpWidget(buildApp(sheetsApi));
        await tapBtn(tester, selected: false);

        final title = S.transitGSSpreadsheetModelDefaultName;
        verify(cache.set(eCacheKey, 'abc:true:' + title));
        verify(cache.set(iCacheKey, 'abc:true:' + title));
      });

      testWidgets('sheets create failed', (tester) async {
        final sheetsApi = getMockSheetsApi();
        when(sheetsApi.spreadsheets.get(
          any,
          $fields: anyNamed('\$fields'),
          includeGridData: anyNamed('includeGridData'),
        )).thenAnswer((_) => Future.value(gs.Spreadsheet()));
        when(sheetsApi.spreadsheets.batchUpdate(
          argThat(predicate<gs.BatchUpdateSpreadsheetRequest>((e) {
            return e.requests?.length == 1 && e.requests?.first.addSheet?.properties?.title == 'title';
          })),
          'id',
        )).thenAnswer((_) => Future.value(gs.BatchUpdateSpreadsheetResponse()));

        await tester.pumpWidget(buildApp(sheetsApi));
        await tapBtn(tester);

        expect(find.text(S.transitGSErrorCreateSheet), findsOneWidget);
      });

      testWidgets('export without new sheets', (tester) async {
        final sheetsApi = getMockSheetsApi();
        gs.Sheet createSheet(String type, int id) {
          return gs.Sheet(
            properties: gs.SheetProperties(title: '$type title', sheetId: id),
          );
        }

        when(cache.get(eCacheKey + '.menu')).thenReturn('m title');
        when(cache.get(eCacheKey + '.stock')).thenReturn('s title');
        when(cache.get(eCacheKey + '.quantities')).thenReturn('q title');
        when(cache.get(eCacheKey + '.orderAttr')).thenReturn('c title');
        when(cache.get(eCacheKey + '.replenisher')).thenReturn('r title');
        prepareData();
        when(sheetsApi.spreadsheets.get(
          any,
          $fields: anyNamed('\$fields'),
          includeGridData: anyNamed('includeGridData'),
        )).thenAnswer((_) => Future.value(
              gs.Spreadsheet(sheets: [
                createSheet('m', 1),
                createSheet('s', 2),
                createSheet('q', 3),
                createSheet('c', 4),
                createSheet('r', 5),
              ]),
            ));
        when(sheetsApi.spreadsheets.batchUpdate(
          any,
          any,
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(gs.BatchUpdateSpreadsheetResponse()));

        await tester.pumpWidget(buildApp(sheetsApi));
        await tapBtn(tester);

        verifyNever(cache.set(eCacheKey + '.stock', any));
        verify(sheetsApi.spreadsheets.batchUpdate(
          argThat(predicate((e) => e is gs.BatchUpdateSpreadsheetRequest && e.requests?.length == 5)),
          any,
          $fields: anyNamed('\$fields'),
        ));

        // which also verify button exist!
        await tester.tap(find.text(S.transitGSSpreadsheetSnackbarAction));
        await tester.pumpAndSettle();

        expect(Launcher.lastUrl, equals('https://docs.google.com/spreadsheets/d/id/edit'));
      });

      testWidgets('export with new sheets', (tester) async {
        final sheetsApi = getMockSheetsApi();
        final sheet = gs.SheetProperties(title: 'new-sheet', sheetId: 2);
        when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
        // getSheets => return empty
        when(sheetsApi.spreadsheets.get(
          any,
          $fields: anyNamed('\$fields'),
          includeGridData: anyNamed('includeGridData'),
        )).thenAnswer((_) => Future.value(gs.Spreadsheet(sheets: [])));
        // updateSheet => ok
        when(sheetsApi.spreadsheets.batchUpdate(any, 'id', $fields: anyNamed('\$fields')))
            .thenAnswer((_) => Future.value(gs.BatchUpdateSpreadsheetResponse()));
        // addSheets => add new-title
        when(sheetsApi.spreadsheets.batchUpdate(
          argThat(predicate<gs.BatchUpdateSpreadsheetRequest>((e) {
            return e.requests?.length == 1 && e.requests?.first.addSheet?.properties?.title == 'new-sheet';
          })),
          'id',
        )).thenAnswer((_) => Future.value(gs.BatchUpdateSpreadsheetResponse(
            replies: [gs.Response(addSheet: gs.AddSheetResponse(properties: sheet))])));

        await tester.pumpWidget(buildApp(sheetsApi));
        await tester.pumpAndSettle();

        // change sheet name
        await tester.longPress(find.byKey(const Key('sheet_namer.stock')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn.edit')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('text_dialog.text')), 'new-sheet');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('text_dialog.confirm')));

        await tapBtn(tester);

        verify(cache.set(eCacheKey + '.stock', 'new-sheet'));
      });

      setUp(() {
        when(cache.get(eCacheKey)).thenReturn('id:true:name');
        when(cache.get(eCacheKey + '.stock')).thenReturn('title');
        final i1 = Ingredient(id: 'i1', name: 'i1');
        Stock.instance.replaceItems({'i1': i1});
      });
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
      initializeCache();
      initializeTranslator();
      initializeAuth();
    });
  });
}
