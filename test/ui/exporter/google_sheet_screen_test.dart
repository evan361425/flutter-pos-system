// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/launcher.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/exporter_routes.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_cache.dart';
import '../../mocks/mock_google_api.dart';
import '../../mocks/mock_storage.dart';
import '../../services/auth_test.mocks.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Google Sheet Screen', () {
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
          title: '',
          exporter: GoogleSheetExporter(
            sheetsApi: sheetsApi,
            scopes: gsExporterScopes,
          ),
          exportScreenBuilder: ExporterRoutes.gsExportScreen,
          importScreenBuilder: ExporterRoutes.gsImportScreen,
        ),
      );
    }

    void prepareData() {
      final i1 = Ingredient(id: 'i1', name: 'i1');
      final i2 = Ingredient(id: 'i2', name: 'i2', currentAmount: 10);
      Stock.instance.replaceItems({'i1': i1, 'i2': i2});

      final q1 = Quantity(id: 'q1', name: 'q1');
      Quantities.instance.replaceItems({'q1': q1});

      final pQ1 = ProductQuantity(id: 'pQ1', quantity: q1);
      final pI1 = ProductIngredient(
          id: 'pI1', ingredient: i1, quantities: {'pQ1': pQ1});
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

    group('Exporter', () {
      testWidgets('#preview', (tester) async {
        Stock.instance.replaceItems({'i1': Ingredient(id: 'i1', name: 'i1')});

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        Checkbox checkbox(String key) =>
            find.byKey(Key('gs_export.$key.checkbox')).evaluate().single.widget
                as Checkbox;
        bool isChecked(String key) => checkbox(key).value == true;

        // only non-empty will check default
        const sheets = [
          'menu',
          'stock',
          'quantities',
          'replenisher',
          'orderAttr'
        ];
        expect(sheets.where(isChecked).length, equals(1));

        checkbox('menu').onChanged!(true);
        await tester.pumpAndSettle();
        expect(sheets.where(isChecked).length, equals(2));

        prepareData();

        Future<void> checkPreview(String key, Iterable<String> values) async {
          await tester.tap(find.byKey(Key('gs_export.$key.preview')));
          await tester.pumpAndSettle();
          for (var value in values) {
            expect(find.text(value), findsOneWidget);
          }
          await tester.tap(find.byIcon(Icons.arrow_back_ios_sharp));
          await tester.pumpAndSettle();
        }

        await checkPreview('stock', ['i1']);
        await checkPreview('quantities', ['q1']);
        await checkPreview('menu', ['c1', 'p1', '- i1,0\n  + q1,0,0,0']);
        await checkPreview('replenisher', ['r1', '- i1,1']);
        await checkPreview('orderAttr', ['cs1', '- o1,false,1\n- o2,true,']);
      });

      group('#export', () {
        Future<void> tapBtn(WidgetTester tester, {bool selected = true}) async {
          await tester.pumpAndSettle();
          await tester.tap(find.text(selected ? '匯出於指定表單' : '匯出後建立試算單'));
          await tester.pumpAndSettle();
        }

        testWidgets('empty checked', (tester) async {
          final notifier = ValueNotifier<String>('');
          Stock.instance.replaceItems({});
          await tester.pumpWidget(
            MaterialApp(
              home: ExporterStation(
                title: '',
                notifier: notifier,
                exporter: GoogleSheetExporter(),
                exportScreenBuilder: ExporterRoutes.gsExportScreen,
                importScreenBuilder: ExporterRoutes.gsImportScreen,
              ),
            ),
          );
          await tapBtn(tester);
          // no repo checked, do nothing
          expect(notifier.value, equals(''));
        });

        testWidgets('repeat name', (tester) async {
          prepareData();
          when(cache.get(eCacheKey + '.menu')).thenReturn('title');
          await tester.pumpWidget(buildApp());
          await tapBtn(tester);
          expect(find.text(S.exporterGSErrors('sheetRepeat')), findsOneWidget);
        });

        testWidgets('spreadsheet create failed', (tester) async {
          final sheetsApi = getMockSheetsApi();
          when(cache.get(eCacheKey)).thenReturn(null);
          when(sheetsApi.spreadsheets.create(
            argThat(predicate<gs.Spreadsheet>((e) {
              return e.sheets?.length == 1 &&
                  e.sheets?.first.properties?.title == 'title';
            })),
            $fields: anyNamed('\$fields'),
          )).thenAnswer((_) => Future.value(gs.Spreadsheet()));

          await tester.pumpWidget(buildApp(sheetsApi));
          await tapBtn(tester, selected: false);

          expect(find.text(S.exporterGSErrors('spreadsheet')), findsOneWidget);
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

          final title = S.exporterGSDefaultSpreadsheetName;
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
              return e.requests?.length == 1 &&
                  e.requests?.first.addSheet?.properties?.title == 'title';
            })),
            'id',
          )).thenAnswer(
              (_) => Future.value(gs.BatchUpdateSpreadsheetResponse()));

          await tester.pumpWidget(buildApp(sheetsApi));
          await tapBtn(tester);

          expect(find.text(S.exporterGSErrors('sheet')), findsOneWidget);
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
          )).thenAnswer(
              (_) => Future.value(gs.BatchUpdateSpreadsheetResponse()));

          await tester.pumpWidget(buildApp(sheetsApi));
          await tapBtn(tester);

          verifyNever(cache.set(eCacheKey + '.stock', 'title'));
          verify(sheetsApi.spreadsheets.batchUpdate(
            any,
            any,
            $fields: anyNamed('\$fields'),
          )).called(5);

          // which also verify button exist!
          await tester.tap(find.text('開啟表單'));
          await tester.pumpAndSettle();

          expect(Launcher.lastUrl,
              equals('https://docs.google.com/spreadsheets/d/id/edit'));
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
          when(sheetsApi.spreadsheets
                  .batchUpdate(any, 'id', $fields: anyNamed('\$fields')))
              .thenAnswer(
                  (_) => Future.value(gs.BatchUpdateSpreadsheetResponse()));
          // addSheets => add new-title
          when(sheetsApi.spreadsheets.batchUpdate(
            argThat(predicate<gs.BatchUpdateSpreadsheetRequest>((e) {
              return e.requests?.length == 1 &&
                  e.requests?.first.addSheet?.properties?.title == 'new-sheet';
            })),
            'id',
          )).thenAnswer((_) => Future.value(
                  gs.BatchUpdateSpreadsheetResponse(replies: [
                gs.Response(addSheet: gs.AddSheetResponse(properties: sheet))
              ])));

          await tester.pumpWidget(buildApp(sheetsApi));
          await tester.pumpAndSettle();

          // change sheet name
          final stock = find.byKey(const Key('gs_export.stock.sheet_namer'));
          await tester.enterText(stock, 'new-sheet');

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
    });

    Future<void> go2Importer(WidgetTester tester) async {
      await tester.tap(find.widgetWithText(Tab, S.btnImport));
      await tester.pumpAndSettle();
    }

    group('Importer', () {
      group('#refresh -', () {
        Future<void> tapBtn(WidgetTester tester, {bool selected = true}) async {
          await tester.tap(find.text(selected ? '檢查所選的試算表' : '選擇試算表'));
          await tester.pump();
        }

        testWidgets('empty spreadsheet need select one', (tester) async {
          await tester.pumpWidget(buildApp());
          await tester.pumpAndSettle();
          await go2Importer(tester);
          await tapBtn(tester, selected: false);

          expect(find.byKey(const Key('text_dialog.text')), findsOneWidget);
        });

        testWidgets('error', (tester) async {
          when(cache.get(iCacheKey)).thenReturn('id:true:name');

          final sheetsApi = getMockSheetsApi();
          await tester.pumpWidget(buildApp(sheetsApi));
          await tester.pumpAndSettle();
          await go2Importer(tester);

          when(sheetsApi.spreadsheets.get(
            'id',
            $fields: anyNamed('\$fields'),
            includeGridData: anyNamed('includeGridData'),
          )).thenAnswer((_) => Future.error('error'));

          await tapBtn(tester);
        });

        testWidgets('success', (tester) async {
          when(cache.get(iCacheKey)).thenReturn('id:true:name');

          final sheetsApi = getMockSheetsApi();
          await tester.pumpWidget(buildApp(sheetsApi));
          await tester.pumpAndSettle();
          await go2Importer(tester);

          final sheet = gs.SheetProperties(sheetId: 1, title: 'new-sheet');
          when(sheetsApi.spreadsheets.get(
            'id',
            $fields: anyNamed('\$fields'),
            includeGridData: anyNamed('includeGridData'),
          )).thenAnswer((_) => Future.value(gs.Spreadsheet(sheets: [
                gs.Sheet(properties: sheet),
              ])));

          await tapBtn(tester);

          final menu = find.byKey(const Key('gs_export.menu.sheet_selector'));
          await tester.tap(menu);
          await tester.pumpAndSettle();
          await tester.tap(find.text('new-sheet').last);
          await tester.pumpAndSettle();
        });
      });

      group('#import -', () {
        Future<void> tapBtn(WidgetTester tester, [int index = 0]) async {
          await tester.pumpAndSettle();
          await go2Importer(tester);

          final btn = find.byIcon(Icons.download_for_offline_outlined);
          await tester.tap(btn.at(index));
          await tester.pumpAndSettle();
        }

        void mockSheetData(
          CustomMockSheetsApi sheetApi,
          List<List<Object>> data, [
          String? title,
        ]) {
          when(sheetApi.spreadsheets.values.get(
            'id',
            argThat(predicate<String>((n) {
              return title == null ? true : n.startsWith("'$title'");
            })),
            majorDimension: anyNamed('majorDimension'),
            $fields: 'values',
          )).thenAnswer((_) => Future.value(gs.ValueRange(values: [
                [], // header
                ...data,
              ])));
        }

        void findText(String text, String status) => expect(
            find.text(
              text + S.importerColumnStatus(status),
              findRichText: true,
            ),
            findsOneWidget);

        testWidgets('spreadsheet not selected', (tester) async {
          when(cache.get(any)).thenReturn(null);
          await tester.pumpWidget(buildApp());
          await tapBtn(tester);

          expect(
              find.text(S.importerGSError('emptySpreadsheet')), findsOneWidget);
        });

        testWidgets('sheet not selected', (tester) async {
          when(cache.get(iCacheKey + '.menu')).thenReturn(null);
          await tester.pumpWidget(buildApp());
          await tapBtn(tester);

          expect(find.text(S.importerGSError('emptySheet')), findsOneWidget);
        });

        testWidgets('empty data', (tester) async {
          final sheetsApi = getMockSheetsApi();
          mockSheetData(sheetsApi, []);

          await tester.pumpWidget(buildApp(sheetsApi));
          await tapBtn(tester);

          expect(find.text('找不到表單「title」的資料'), findsOneWidget);
        });

        testWidgets('pop preview source', (tester) async {
          const ing = '- i1,1\n  + q1,1,1,1\n  + q2';
          final sheetsApi = getMockSheetsApi();
          final notifier = ValueNotifier<String>('');
          mockSheetData(sheetsApi, [
            ['c1', 'p1', 1, 1],
            ['c1', 'p2', 2, 2, ing],
          ]);

          await tester.pumpWidget(MaterialApp(
            home: ExporterStation(
              title: '',
              notifier: notifier,
              exporter: GoogleSheetExporter(
                sheetsApi: sheetsApi,
                scopes: gsExporterScopes,
              ),
              exportScreenBuilder: ExporterRoutes.gsExportScreen,
              importScreenBuilder: ExporterRoutes.gsImportScreen,
            ),
          ));
          await tapBtn(tester);

          expect(find.text(ing), findsOneWidget);
          expect(notifier.value, equals('驗證身份中'));

          await tester.tap(find.byIcon(Icons.arrow_back_ios_sharp));
          await tester.pumpAndSettle();

          expect(notifier.value, equals('_finish'));
        });

        testWidgets('menu(commit)', (tester) async {
          final sheetsApi = getMockSheetsApi();

          await tester.pumpWidget(buildApp(sheetsApi));
          await tester.pumpAndSettle();
          await go2Importer(tester);

          // change sheet name
          final sheet = gs.SheetProperties(sheetId: 2, title: 'new-sheet');
          when(sheetsApi.spreadsheets.get(
            'id',
            includeGridData: anyNamed('includeGridData'),
            $fields: anyNamed('\$fields'),
          )).thenAnswer((_) => Future.value(gs.Spreadsheet(sheets: [
                gs.Sheet(properties: sheet),
              ])));
          await tester.tap(find.text('檢查所選的試算表'));
          await tester.pumpAndSettle();
          final menu = find.byKey(const Key('gs_export.menu.sheet_selector'));
          await tester.tap(menu);
          await tester.pumpAndSettle();
          await tester.tap(find.text('new-sheet').last);
          await tester.pumpAndSettle();

          mockSheetData(sheetsApi, [
            ['c1', 'p1', 1, 1, '- i1,1\n  + q1,1,1,1\n  + q2'],
            ['c1', 'p2', 2, 2],
            ['c2', 'p2', 2, 2],
            ['c2', 'p3', 3, 3],
          ]);
          when(cache.set(any, any)).thenAnswer((_) => Future.value(true));

          final btn = find.byIcon(Icons.download_for_offline_outlined);
          await tester.tap(btn.first);
          await tester.pumpAndSettle();

          verify(cache.set(iCacheKey + '.menu', 'new-sheet 2'));

          await tester.tap(find.text(S.importPreviewerTitle));
          await tester.pumpAndSettle();

          for (var e in ['p1', 'p2', 'p3', 'c1', 'c2']) {
            findText(e, 'staged');
          }
          expect(find.text('將忽略本行，相同的項目已於前面出現'), findsOneWidget);

          await tester.tap(find.byType(ExpansionTile).first);
          await tester.pumpAndSettle();

          findText('i1', 'stagedIng');
          findText('q1', 'stagedQua');
          findText('q2', 'stagedQua');

          await tester.tap(find.text(S.btnSave));
          await tester.pumpAndSettle();

          expect(Stock.instance.length, equals(1));
          expect(Quantities.instance.length, equals(2));
          expect(Menu.instance.length, equals(2));
          final pNames = Menu.instance.products.map((e) => e.name).toList();
          expect(pNames, equals(['p1', 'p2', 'p3']));
          final p1 = Menu.instance.getProductByName('p1');
          expect(p1?.length, equals(1));
          expect(p1?.getItemByName('i1')?.length, equals(2));
        });

        Future<void> prepareImport(
          WidgetTester tester,
          String name,
          int index,
          bool commit,
          List<List<Object>> data, [
          List<String>? names,
        ]) async {
          when(cache.get(iCacheKey + '.$name')).thenReturn('title 1');
          final sheetsApi = getMockSheetsApi();
          mockSheetData(sheetsApi, data);

          await tester.pumpWidget(buildApp(sheetsApi));
          await tapBtn(tester, index);
          await tester.tap(find.text(S.importPreviewerTitle));
          await tester.pumpAndSettle();

          if (names == null) {
            for (var item in data) {
              findText(item[0] as String, 'staged');
            }
          } else {
            for (var item in names) {
              findText(item, 'staged');
            }
          }

          await tester.tap(
              commit ? find.text(S.btnSave) : find.byIcon(Icons.clear_sharp));
          await tester.pumpAndSettle();
        }

        testWidgets('menu(abort)', (tester) async {
          await prepareImport(tester, 'menu', 0, false, [
            ['c1', 'p1', 1, 1, '- i1,1\n  + q1,1,1,1\n  + q2'],
          ]);

          expect(Stock.instance.isEmpty, isTrue);
          expect(Quantities.instance.isEmpty, isTrue);
          expect(Menu.instance.isEmpty, isTrue);
          expect(Stock.instance.stagedItems.isEmpty, isTrue);
          expect(Quantities.instance.stagedItems.isEmpty, isTrue);
          expect(Menu.instance.stagedItems.isEmpty, isTrue);
        });

        testWidgets('stock', (tester) async {
          Stock.instance.replaceItems({'i0': Ingredient(id: 'i0')});
          await prepareImport(tester, 'stock', 1, true, [
            ['i1', 1],
            ['i2'],
            ['i3', -2],
          ], [
            'i1',
            'i2'
          ]);

          // should not reset old value
          expect(Stock.instance.length, equals(3));
          expect(Stock.instance.getItem('i0'), isNotNull);
          expect(Stock.instance.getItemByName('i1'), isNotNull);
        });

        testWidgets('quantities', (tester) async {
          Quantities.instance.replaceItems({'q0': Quantity(id: 'q0')});
          await prepareImport(tester, 'quantities', 2, true, [
            ['q1', 2],
            ['q2'],
          ]);

          // should not reset old value
          expect(Quantities.instance.length, equals(3));
          expect(Quantities.instance.getItem('q0'), isNotNull);
          expect(Quantities.instance.getItemByName('q1'), isNotNull);
        });

        testWidgets('replenisher(commit)', (tester) async {
          await prepareImport(tester, 'replenisher', 3, true, [
            ['r1', '- i1,20\n- i2,-5'],
            ['r2'],
          ]);

          expect(Stock.instance.length, equals(2));
          expect(Stock.instance.getItemByName('i2'), isNotNull);
          expect(Replenisher.instance.length, equals(2));
          expect(Replenisher.instance.getItemByName('r1'), isNotNull);
        });

        testWidgets('replenisher(abort)', (tester) async {
          await prepareImport(tester, 'replenisher', 3, false, [
            ['r1', '- i1,20\n- i2,-5'],
            ['r2'],
          ]);

          expect(Stock.instance.isEmpty, isTrue);
          expect(Stock.instance.stagedItems.isEmpty, isTrue);
          expect(Replenisher.instance.isEmpty, isTrue);
          expect(Replenisher.instance.stagedItems.isEmpty, isTrue);
        });

        testWidgets('orderAttribute', (tester) async {
          await prepareImport(tester, 'orderAttr', 4, true, [
            ['c1', '折扣', '- co1,true\n- co2,,5'],
            ['c2'],
          ]);

          verify(storage.reset(Stores.orderAttributes)).called(1);
          verify(storage.add(Stores.orderAttributes, any, any)).called(2);

          expect(OrderAttributes.instance.length, equals(2));

          final items = OrderAttributes.instance.itemList;
          expect(items[0].name, equals('c1'));
          expect(items[1].name, equals('c2'));

          final options = items.first.itemList;
          expect(options[0].name, equals('co1'));
          expect(options[1].name, equals('co2'));
        });

        testWidgets('menu + stock', (tester) async {
          when(cache.get(iCacheKey + '.stock')).thenReturn('stock 2');
          final sheetsApi = getMockSheetsApi();
          final data1 = [
            ['c1', 'p1', 1, 1, '- i1,1\n  + q1,1,1,1\n  + q2'],
          ];
          final data2 = [
            ['i1', 1],
            ['i2'],
            ['i3', -2],
          ];
          mockSheetData(sheetsApi, data1, 'title');
          mockSheetData(sheetsApi, data2, 'stock');

          await tester.pumpWidget(buildApp(sheetsApi));
          await tester.pumpAndSettle();
          await go2Importer(tester);

          await tester.tap(find.byKey(const Key('gs_export.import_all')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
          await tester.pumpAndSettle();
          await tester.pumpAndSettle();

          // should not reset old value
          expect(Stock.instance.length, equals(2));
          expect(Stock.instance.getItemByName('i1'), isNotNull);
          expect(Menu.instance.length, equals(1));
        });

        setUp(() {
          reset(storage);
          when(cache.get(iCacheKey)).thenReturn('id:true:name');
          when(cache.get(iCacheKey + '.menu')).thenReturn('title 1');
          when(storage.add(any, any, any)).thenAnswer((_) => Future.value());
          when(storage.reset(any)).thenAnswer((_) => Future.value());
        });
      });
    });

    group('#pickSpreadsheet -', () {
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

      TextField getNamer(String label) {
        return find
            .byKey(Key('gs_export.$label.sheet_namer'))
            .evaluate()
            .single
            .widget as TextField;
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
        final sheetsApi = getMockSheetsApi();
        mockPick(sheetsApi, spreadsheetId, 'some-sheet');

        await tester.pumpWidget(buildApp(sheetsApi));
        await tester.pumpAndSettle();
        expect(getNamer('menu').autofillHints, isNull);

        await action(tester);

        final editor = find.byKey(const Key('text_dialog.text'));
        final editorW = editor.evaluate().single.widget as TextFormField;
        expect(editorW.controller?.text, isEmpty);

        await tester.enterText(editor, spreadsheetId);
        await tester.tap(find.byKey(const Key('text_dialog.confirm')));
        await tester.pumpAndSettle();

        expect(getNamer('menu').autofillHints, equals(['some-sheet']));
        verify(cache.set(eCacheKey, '$spreadsheetId:false:title'));
      });

      testWidgets('export cancel old', (tester) async {
        clearInteractions(cache);
        when(cache.get(eCacheKey)).thenReturn('id:true:name');
        when(cache.get(eCacheKey + '.menu')).thenReturn('menu');

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(getNamer('menu').controller?.text, equals('menu'));

        await action(tester, Icons.add_box_outlined);
        await tester.pumpAndSettle();

        // should not change
        expect(getNamer('menu').controller?.text, equals('menu'));
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
        await go2Importer(tester);

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
      initializeStorage();
      initializeCache();
      initializeAuth();
    });
  });
}
