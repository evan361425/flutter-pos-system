// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/transit_station.dart';

import '../../../mocks/mock_auth.dart';
import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_google_api.dart';
import '../../../mocks/mock_storage.dart';
import '../../../services/auth_test.mocks.dart';
import '../../../test_helpers/breakpoint_mocker.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - Google Sheet - Import Basic', () {
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

    Future<void> go2Importer(WidgetTester tester) async {
      await tester.tap(find.widgetWithText(Tab, S.transitImportBtn));
      await tester.pumpAndSettle();
    }

    group('#refresh -', () {
      Future<void> tapBtn(WidgetTester tester, {bool selected = true}) async {
        await tester.tap(find.text(
          selected ? S.transitGSSpreadsheetImportExistLabel : S.transitGSSpreadsheetImportEmptyLabel,
        ));
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

        // scroll down
        await tester.drag(
          find.byIcon(Icons.remove_red_eye_outlined).first,
          const Offset(0, -1000),
        );
        await tester.pumpAndSettle();

        final btn = find.byIcon(Icons.remove_red_eye_outlined);
        await tester.tap(btn.at(index));
        await tester.pump();
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
            text + S.transitImportColumnStatus(status),
            findRichText: true,
          ),
          findsOneWidget);

      testWidgets('spreadsheet not selected', (tester) async {
        when(cache.get(any)).thenReturn(null);
        await tester.pumpWidget(buildApp());
        await tapBtn(tester);

        expect(find.text(S.transitGSErrorImportEmptySpreadsheet), findsOneWidget);
      });

      testWidgets('sheet not selected', (tester) async {
        when(cache.get(iCacheKey + '.menu')).thenReturn(null);
        await tester.pumpWidget(buildApp());
        await tapBtn(tester);

        expect(find.text(S.transitGSErrorImportEmptySheet), findsOneWidget);
      });

      testWidgets('empty data', (tester) async {
        final sheetsApi = getMockSheetsApi();
        mockSheetData(sheetsApi, []);

        await tester.pumpWidget(buildApp(sheetsApi));
        await tapBtn(tester);

        expect(find.text(S.transitGSErrorImportNotFoundSheets('title')), findsOneWidget);
      });

      for (final device in [Device.desktop, Device.mobile]) {
        group(device.name, () {
          testWidgets('pop preview source', (tester) async {
            deviceAs(device, tester);
            const ing = '- i1,1\n  + q1,1,1,1\n  + q2';
            final sheetsApi = getMockSheetsApi();
            final notifier = ValueNotifier<String>('');
            mockSheetData(sheetsApi, [
              ['c1', 'p1', 1, 1],
              ['c1', 'p2', 2, 2, ing],
            ]);

            await tester.pumpWidget(MaterialApp.router(
              routerConfig: GoRouter(
                navigatorKey: Routes.rootNavigatorKey,
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (_, __) => TransitStation(
                      catalog: TransitCatalog.model,
                      notifier: notifier,
                      exporter: GoogleSheetExporter(
                        sheetsApi: sheetsApi,
                        scopes: gsExporterScopes,
                      ),
                      method: TransitMethod.googleSheet,
                    ),
                  ),
                ],
              ),
            ));
            await tapBtn(tester);

            expect(find.text(ing), findsOneWidget);
            expect(notifier.value, equals(S.transitGSProgressStatusVerifyUser));

            await tester.tap(find.byKey(const Key('pop')).last);
            await tester.pumpAndSettle();

            expect(notifier.value, equals('_finish'));
          });
        });
      }

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
        await tester.tap(find.text(S.transitGSSpreadsheetImportExistLabel));
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

        final btn = find.byIcon(Icons.remove_red_eye_outlined);
        await tester.tap(btn.first);
        await tester.pump();

        verify(cache.set(iCacheKey + '.menu', 'new-sheet 2'));

        await tester.tap(find.text(S.transitImportPreviewBtn));
        await tester.pump();

        for (var e in ['p1', 'p2', 'p3', 'c1', 'c2']) {
          findText(e, 'staged');
        }
        expect(find.text(S.transitImportErrorDuplicate), findsOneWidget);

        await tester.tap(find.byType(ExpansionTile).first);
        await tester.pump();

        findText('i1', 'stagedIng');
        findText('q1', 'stagedQua');
        findText('q2', 'stagedQua');

        await tester.tap(find.text('Save'));
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
        await tester.tap(find.text(S.transitImportPreviewBtn));
        await tester.pump();

        if (names == null) {
          for (var item in data) {
            findText(item[0] as String, 'staged');
          }
        } else {
          for (var item in names) {
            findText(item, 'staged');
          }
        }

        await tester.tap(commit ? find.text('Save') : find.byIcon(Icons.close));
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
          ['i3', 1, 1, -2],
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
          ['c1', S.orderAttributeModeName('changeDiscount'), '- co1,true\n- co2,,5'],
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
      initializeStorage();
      initializeCache();
      initializeTranslator();
      initializeAuth();
    });
  });
}
