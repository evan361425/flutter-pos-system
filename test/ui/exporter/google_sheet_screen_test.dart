import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' as gd;
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/google_sheet_screen.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_database.dart';
import '../../mocks/mock_google_api.dart';
import '../../mocks/mock_storage.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Google Sheet Screen', () {
    const eCacheIdKey = 'exporter_google_sheet_id';
    const iCacheIdKey = 'importer_google_sheet_id';
    const eCacheNameKey = 'exporter_google_sheet_name';
    const iCacheNameKey = 'importer_google_sheet_name';

    Future<void> go2Importer(WidgetTester tester) async {
      await tester.tap(find.widgetWithText(Tab, S.btnImport));
      await tester.pumpAndSettle();
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

      final o1 = CustomerSettingOption(id: 'o1', name: 'o1', modeValue: 1);
      final o2 = CustomerSettingOption(id: 'o2', name: 'o2', isDefault: true);
      final cs1 = CustomerSetting(id: 'cs1', name: 'cs1', options: {
        'o1': o1,
        'o2': o2,
      });
      cs1.prepareItem();
      CustomerSettings.instance.replaceItems({'cs1': cs1});
    }

    group('Exporter', () {
      testWidgets('preview', (tester) async {
        Stock.instance.replaceItems({'i1': Ingredient(id: 'i1', name: 'i1')});

        await tester.pumpWidget(const MaterialApp(home: GoogleSheetScreen()));
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
          'customer'
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
        await checkPreview('customer', ['cs1', '- o1,false,1\n- o2,true,']);
      });
    });

    group('Importer', () {
      group('#refresh -', () {
        testWidgets('failed', (tester) async {
          await tester.pumpWidget(MaterialApp(
            home: GoogleSheetScreen(exporter: GoogleSheetExporter()),
          ));
          await tester.pumpAndSettle();
          await go2Importer(tester);

          await tester.tap(find.byIcon(Icons.refresh_outlined));
          await tester.pumpAndSettle();

          expect(find.text(S.importerGSError('empty_spreadsheet')),
              findsOneWidget);
        });

        testWidgets('error', (tester) async {
          when(cache.get(iCacheIdKey)).thenReturn('id');
          when(cache.get(iCacheNameKey)).thenReturn('name');

          final sheetsApi = getMockSheetsApi();
          await tester.pumpWidget(MaterialApp(
            home: GoogleSheetScreen(
              exporter: GoogleSheetExporter(sheetsApi: sheetsApi),
            ),
          ));
          await tester.pumpAndSettle();
          await go2Importer(tester);

          when(sheetsApi.spreadsheets.get('id', $fields: anyNamed('\$fields')))
              .thenAnswer((_) => Future.error('error'));

          await tester.tap(find.byIcon(Icons.refresh_outlined));
          await tester.pumpAndSettle();
        });

        testWidgets('success', (tester) async {
          when(cache.get(iCacheIdKey)).thenReturn('id');
          when(cache.get(iCacheNameKey)).thenReturn('name');

          final sheetsApi = getMockSheetsApi();
          await tester.pumpWidget(MaterialApp(
            home: GoogleSheetScreen(
              exporter: GoogleSheetExporter(sheetsApi: sheetsApi),
            ),
          ));
          await tester.pumpAndSettle();
          await go2Importer(tester);

          final sheet = gs.SheetProperties(sheetId: 1, title: 'new-sheet');
          when(sheetsApi.spreadsheets.get('id', $fields: anyNamed('\$fields')))
              .thenAnswer((_) => Future.value(gs.Spreadsheet(sheets: [
                    gs.Sheet(properties: sheet),
                  ])));

          await tester.tap(find.byIcon(Icons.refresh_outlined));
          await tester.pumpAndSettle();

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
          List<List<Object>> data,
        ) {
          when(sheetApi.spreadsheets.values.get(
            'id',
            any,
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
          await tester.pumpWidget(MaterialApp(
            home: GoogleSheetScreen(exporter: GoogleSheetExporter()),
          ));
          await tapBtn(tester);

          expect(find.text(S.importerGSError('empty_spreadsheet')),
              findsOneWidget);
        });

        testWidgets('sheet not selected', (tester) async {
          when(cache.get(iCacheNameKey + '.menu')).thenReturn(null);
          await tester.pumpWidget(MaterialApp(
            home: GoogleSheetScreen(exporter: GoogleSheetExporter()),
          ));
          await tapBtn(tester);

          expect(find.text(S.importerGSError('empty_sheet')), findsOneWidget);
        });

        testWidgets('empty data', (tester) async {
          final sheetApi = getMockSheetsApi();
          mockSheetData(sheetApi, []);

          await tester.pumpWidget(MaterialApp(
            home: GoogleSheetScreen(
              exporter: GoogleSheetExporter(
                sheetsApi: sheetApi,
              ),
            ),
          ));
          await tapBtn(tester);

          expect(find.text(S.importerGSError('empty_data')), findsOneWidget);
        });

        testWidgets('pop preview source', (tester) async {
          const ing = '- i1,1\n  + q1,1,1,1\n  + q2';
          final sheetApi = getMockSheetsApi();
          final screen = GlobalKey<GoogleSheetScreenState>();
          mockSheetData(sheetApi, [
            ['c1', 'p1', 1, 1],
            ['c1', 'p2', 2, 2, ing],
          ]);

          await tester.pumpWidget(MaterialApp(
            home: GoogleSheetScreen(
              key: screen,
              exporter: GoogleSheetExporter(
                sheetsApi: sheetApi,
              ),
            ),
          ));
          await tapBtn(tester);

          expect(find.text(ing), findsOneWidget);
          expect(screen.currentState?.loading.currentState?.isLoading, isTrue);

          await tester.tap(find.byIcon(Icons.arrow_back_ios_sharp));
          await tester.pumpAndSettle();

          expect(screen.currentState?.loading.currentState?.isLoading, isFalse);
        });

        testWidgets('menu(commit)', (tester) async {
          final sheetApi = getMockSheetsApi();
          mockSheetData(sheetApi, [
            ['c1', 'p1', 1, 1, '- i1,1\n  + q1,1,1,1\n  + q2'],
            ['c1', 'p2', 2, 2],
            ['c2', 'p2', 2, 2],
            ['c2', 'p3', 3, 3],
          ]);

          await tester.pumpWidget(MaterialApp(
            home: GoogleSheetScreen(
              exporter: GoogleSheetExporter(
                sheetsApi: sheetApi,
              ),
            ),
          ));
          await tapBtn(tester);
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
          List<List<Object>> data,
        ) async {
          when(cache.get(iCacheNameKey + '.$name')).thenReturn('title 1');
          final sheetApi = getMockSheetsApi();
          mockSheetData(sheetApi, data);

          await tester.pumpWidget(MaterialApp(
            home: GoogleSheetScreen(
              exporter: GoogleSheetExporter(
                sheetsApi: sheetApi,
              ),
            ),
          ));
          await tapBtn(tester, index);
          await tester.tap(find.text(S.importPreviewerTitle));
          await tester.pumpAndSettle();

          for (var item in data) {
            findText(item[0] as String, 'staged');
          }

          await tester.tap(
            commit ? find.text(S.btnSave) : find.byIcon(Icons.clear_sharp),
          );
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
          await prepareImport(tester, 'stock', 1, true, [
            ['i1', 1],
            ['i2'],
          ]);

          expect(Stock.instance.length, equals(2));
          expect(Stock.instance.getItemByName('i1'), isNotNull);
        });

        testWidgets('quantities', (tester) async {
          await prepareImport(tester, 'quantities', 2, true, [
            ['q1', 2],
            ['q2'],
          ]);

          expect(Quantities.instance.length, equals(2));
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

        testWidgets('customer', (tester) async {
          when(database.push(any, any)).thenAnswer((_) => Future.value(0));
          when(database.reset(any)).thenAnswer((_) => Future.value());
          await prepareImport(tester, 'customer', 4, true, [
            ['c1', '折扣', '- co1,true\n- co2,,5'],
            ['c2'],
          ]);

          expect(CustomerSettings.instance.length, equals(2));
          expect(CustomerSettings.instance.getItemByName('c1'), isNotNull);
        });

        setUp(() {
          when(cache.get(iCacheIdKey)).thenReturn('id');
          when(cache.get(iCacheNameKey)).thenReturn('name');
          when(cache.get(iCacheNameKey + '.menu')).thenReturn('title 1');
          when(storage.add(any, any, any)).thenAnswer((_) => Future.value());
          when(storage.reset(any)).thenAnswer((_) => Future.value());
        });
      });
    });

    group('#pickSpreadsheet -', () {
      DropdownButtonFormField<GoogleSheetProperties> getSelector(
        String label,
      ) {
        return find
            .byKey(Key('gs_export.$label.sheet_selector'))
            .evaluate()
            .single
            .widget as DropdownButtonFormField<GoogleSheetProperties>;
      }

      TextField getNamer(String label) {
        return find
            .byKey(Key('gs_export.$label.sheet_namer'))
            .evaluate()
            .single
            .widget as TextField;
      }

      void mockPick(
        CustomMockDriveApi driveApi,
        CustomMockSheetsApi sheetsApi,
      ) {
        FilePicker.platform = _FakeFilePicker('new-name');
        final files = gd.FileList(files: [gd.File(id: 'new-id')]);
        final sheet1 = gs.SheetProperties(title: 'new-sheet', sheetId: 1);

        when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
        when(driveApi.mockFiles.list(
          q: argThat(contains("name = 'new-name'"), named: 'q'),
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(files));
        when(sheetsApi.mockSpreadsheets.get(
          argThat(equals('new-id')),
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(
            gs.Spreadsheet(sheets: [gs.Sheet(properties: sheet1)])));
      }

      testWidgets('exporter pick failed', (tester) async {
        when(cache.get(eCacheIdKey)).thenReturn('old-id');
        when(cache.get(eCacheNameKey)).thenReturn('old-name');

        final screen = GlobalKey<GoogleSheetScreenState>();
        await tester.pumpWidget(MaterialApp(
          home: GoogleSheetScreen(key: screen),
        ));
        await tester.pumpAndSettle();

        FilePicker.platform = _FakeFilePicker(null);

        final picker = find.byKey(const Key('gs_export.exporter_spreadsheet'));
        final pickerW = picker.evaluate().single.widget as TextField;
        expect(pickerW.controller?.text, equals('old-name'));

        await tester.tap(picker);
        expect(screen.currentState?.loading.currentState?.isLoading, isTrue);

        await tester.pumpAndSettle();
        expect(screen.currentState?.loading.currentState?.isLoading, isFalse);
        expect(pickerW.controller?.text, equals('old-name'));
      });

      testWidgets('exporter pick not exist', (tester) async {
        final screen = GlobalKey<GoogleSheetScreenState>();
        final driveApi = getMockDriveApi();
        await tester.pumpWidget(MaterialApp(
          home: GoogleSheetScreen(
            key: screen,
            exporter: GoogleSheetExporter(driveApi: driveApi),
          ),
        ));
        await tester.pumpAndSettle();

        FilePicker.platform = _FakeFilePicker('deleted');
        when(driveApi.mockFiles.list(
          q: argThat(contains("name = 'deleted'"), named: 'q'),
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(gd.FileList()));

        final picker = find.byKey(const Key('gs_export.exporter_spreadsheet'));
        final pickerW = picker.evaluate().single.widget as TextField;
        await tester.tap(picker);
        await tester.pumpAndSettle();

        expect(screen.currentState?.loading.currentState?.isLoading, isFalse);
        expect(pickerW.controller?.text, isEmpty);

        FilePicker.platform = _FakeFilePicker('new-name');
        when(driveApi.mockFiles.list(
          q: anyNamed('q'),
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.error('some-error'));

        // wait for error message disappear
        await tester.pump(const Duration(seconds: 4));
        await tester.tap(picker);
        await tester.pumpAndSettle();
        expect(find.text(S.actError), findsOneWidget);
      });

      testWidgets('exporter pick new', (tester) async {
        final screen = GlobalKey<GoogleSheetScreenState>();
        final driveApi = getMockDriveApi();
        final sheetsApi = getMockSheetsApi();
        await tester.pumpWidget(MaterialApp(
          home: GoogleSheetScreen(
            key: screen,
            exporter: GoogleSheetExporter(
              driveApi: driveApi,
              sheetsApi: sheetsApi,
            ),
          ),
        ));
        await tester.pumpAndSettle();

        mockPick(driveApi, sheetsApi);

        final picker = find.byKey(const Key('gs_export.exporter_spreadsheet'));
        final pickerW = picker.evaluate().single.widget as TextField;
        expect(getNamer('menu').autofillHints, isNull);
        expect(pickerW.controller?.text, isEmpty);

        await tester.tap(picker);
        await tester.pumpAndSettle();

        expect(pickerW.controller?.text, equals('new-name'));
        expect(getNamer('menu').autofillHints, equals(['new-sheet']));
        verify(cache.set(eCacheIdKey, 'new-id'));
        verify(cache.set(eCacheNameKey, 'new-name'));
        expect(screen.currentState?.loading.currentState?.isLoading, isFalse);
      });

      testWidgets('export cancel old', (tester) async {
        when(cache.get(eCacheIdKey)).thenReturn('id');
        when(cache.get(eCacheNameKey)).thenReturn('name');
        when(cache.get(eCacheNameKey + '.menu')).thenReturn('menu');

        await tester.pumpWidget(const MaterialApp(home: GoogleSheetScreen()));
        await tester.pumpAndSettle();

        final pFinder = find.byKey(const Key('gs_export.exporter_spreadsheet'));
        final picker = pFinder.evaluate().single.widget as TextField;

        expect(picker.controller?.text, equals('name'));
        expect(getNamer('menu').controller?.text, equals('menu'));

        await tester.tap(find.byIcon(Icons.clear_sharp));
        await tester.pumpAndSettle();

        expect(picker.controller?.text, isEmpty);
        // should not change
        expect(getNamer('menu').controller?.text, equals('menu'));
      });

      testWidgets('importer pick new', (tester) async {
        when(cache.get(iCacheIdKey)).thenReturn('old-id');
        when(cache.get(iCacheNameKey)).thenReturn('old-name');
        // test each situation when parsing
        when(cache.get(iCacheNameKey + '.menu')).thenReturn('menu title 1');
        when(cache.get(iCacheNameKey + '.stock')).thenReturn('stock');
        when(cache.get(iCacheNameKey + '.customer')).thenReturn('customer a');

        final driveApi = getMockDriveApi();
        final sheetsApi = getMockSheetsApi();
        await tester.pumpWidget(MaterialApp(
          home: GoogleSheetScreen(
            exporter: GoogleSheetExporter(
              driveApi: driveApi,
              sheetsApi: sheetsApi,
            ),
          ),
        ));
        await tester.pumpAndSettle();
        await go2Importer(tester);

        final picker = find.byKey(const Key('gs_export.importer_spreadsheet'));
        final pickerW = picker.evaluate().single.widget as TextField;
        expect(getSelector('menu').initialValue?.title, equals('menu title'));
        expect(getSelector('menu').initialValue?.id, equals(1));
        expect(getSelector('stock').initialValue, isNull);
        expect(getSelector('customer').initialValue, isNull);
        expect(pickerW.controller?.text, equals('old-name'));

        mockPick(driveApi, sheetsApi);

        await tester.tap(picker);
        await tester.pumpAndSettle();

        expect(pickerW.controller?.text, equals('new-name'));
        verify(cache.set(iCacheIdKey, 'new-id'));
        verify(cache.set(iCacheNameKey, 'new-name'));

        Future<void> tapSelector(String l) =>
            tester.tap(find.byKey(Key('gs_export.$l.sheet_selector')));

        // both mene and stock (and others) exist new sheet options
        await tapSelector('menu');
        await tester.pumpAndSettle();
        await tester.tap(find.text('new-sheet').last);
        await tester.pumpAndSettle();
        await tapSelector('stock');
        await tester.pumpAndSettle();
        await tester.tap(find.text('new-sheet').last);
        await tester.pumpAndSettle();
      });
    });

    setUp(() {
      Menu();
      Stock();
      Quantities();
      CustomerSettings();
      Replenisher();
      when(cache.get(any)).thenReturn(null);
    });

    setUpAll(() {
      initializeTranslator();
      initializeStorage();
      initializeCache();
      initializeDatabase();
    });
  });
}

class _FakeFilePicker extends FilePicker {
  final String? name;

  _FakeFilePicker(this.name);

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus p1)? onFileLoading,
    bool allowCompression = true,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return FilePickerResult(
      name == null ? [] : [PlatformFile(name: name!, size: 0)],
    );
  }
}
