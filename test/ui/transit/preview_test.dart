import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
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

  testWidgets('preview', (tester) async {
    Stock.instance.replaceItems({'i1': Ingredient(id: 'i1', name: 'i1')});

    // await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

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

  // Future<void> tapBtn(WidgetTester tester, [int index = 0]) async {
  //   await tester.pumpAndSettle();
  //   await go2Importer(tester);

  //   // scroll down
  //   await tester.drag(
  //     find.byIcon(Icons.remove_red_eye_outlined).first,
  //     const Offset(0, -1000),
  //   );
  //   await tester.pumpAndSettle();

  //   final btn = find.byIcon(Icons.remove_red_eye_outlined);
  //   await tester.tap(btn.at(index));
  //   await tester.pump();
  // }

  // void mockSheetData(
  //   CustomMockSheetsApi sheetApi,
  //   List<List<Object>> data, [
  //   String? title,
  // ]) {
  //   when(sheetApi.spreadsheets.values.get(
  //     'id',
  //     argThat(predicate<String>((n) {
  //       return title == null ? true : n.startsWith("'$title'");
  //     })),
  //     majorDimension: anyNamed('majorDimension'),
  //     $fields: 'values',
  //   )).thenAnswer((_) => Future.value(gs.ValueRange(values: [
  //         [], // header
  //         ...data,
  //       ])));
  // }

  // void findText(String text, String status) => expect(
  //     find.text(
  //       text + S.transitImportColumnStatus(status),
  //       findRichText: true,
  //     ),
  //     findsOneWidget);

  // testWidgets('empty data', (tester) async {
  //   final sheetsApi = getMockSheetsApi();
  //   mockSheetData(sheetsApi, []);

  //   await tester.pumpWidget(buildApp(sheetsApi));
  //   await tapBtn(tester);

  //   expect(find.text(S.transitGSErrorImportNotFoundSheets('title')), findsOneWidget);
  // });

  // for (final device in [Device.desktop, Device.mobile]) {
  //   group(device.name, () {
  //     testWidgets('pop preview source', (tester) async {
  //       deviceAs(device, tester);
  //       const ing = '- i1,1\n  + q1,1,1,1\n  + q2';
  //       final sheetsApi = getMockSheetsApi();
  //       final notifier = ValueNotifier<String>('');
  //       mockSheetData(sheetsApi, [
  //         ['c1', 'p1', 1, 1],
  //         ['c1', 'p2', 2, 2, ing],
  //       ]);

  //       await tester.pumpWidget(MaterialApp.router(
  //         routerConfig: GoRouter(
  //           navigatorKey: Routes.rootNavigatorKey,
  //           routes: [
  //             GoRoute(
  //               path: '/',
  //               builder: (_, __) => TransitStation(
  //                 catalog: TransitCatalog.model,
  //                 notifier: notifier,
  //                 exporter: GoogleSheetExporter(
  //                   sheetsApi: sheetsApi,
  //                   scopes: gsExporterScopes,
  //                 ),
  //                 method: TransitMethod.googleSheet,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ));
  //       await tapBtn(tester);

  //       expect(find.text(ing), findsOneWidget);
  //       expect(notifier.value, equals(S.transitGSProgressStatusVerifyUser));

  //       await tester.tap(find.byKey(const Key('pop')).last);
  //       await tester.pumpAndSettle();

  //       expect(notifier.value, equals('_finish'));
  //     });
  //   });
  // }

  // testWidgets('menu(commit)', (tester) async {
  //   final sheetsApi = getMockSheetsApi();

  //   await tester.pumpWidget(buildApp(sheetsApi));
  //   await tester.pumpAndSettle();
  //   await go2Importer(tester);

  //   // change sheet name
  //   final sheet = gs.SheetProperties(sheetId: 2, title: 'new-sheet');
  //   when(sheetsApi.spreadsheets.get(
  //     'id',
  //     includeGridData: anyNamed('includeGridData'),
  //     $fields: anyNamed('\$fields'),
  //   )).thenAnswer((_) => Future.value(gs.Spreadsheet(sheets: [
  //         gs.Sheet(properties: sheet),
  //       ])));
  //   await tester.tap(find.text(S.transitGSSpreadsheetImportExistLabel));
  //   await tester.pumpAndSettle();
  //   final menu = find.byKey(const Key('gs_export.menu.sheet_selector'));
  //   await tester.tap(menu);
  //   await tester.pumpAndSettle();
  //   await tester.tap(find.text('new-sheet').last);
  //   await tester.pumpAndSettle();

  //   mockSheetData(sheetsApi, [
  //     ['c1', 'p1', 1, 1, '- i1,1\n  + q1,1,1,1\n  + q2'],
  //     ['c1', 'p2', 2, 2],
  //     ['c2', 'p2', 2, 2],
  //     ['c2', 'p3', 3, 3],
  //   ]);
  //   when(cache.set(any, any)).thenAnswer((_) => Future.value(true));

  //   final btn = find.byIcon(Icons.remove_red_eye_outlined);
  //   await tester.tap(btn.first);
  //   await tester.pump();

  //   verify(cache.set(iCacheKey + '.menu', 'new-sheet 2'));

  //   await tester.tap(find.text(S.transitImportPreviewBtn));
  //   await tester.pump();

  //   for (var e in ['p1', 'p2', 'p3', 'c1', 'c2']) {
  //     findText(e, 'staged');
  //   }
  //   expect(find.text(S.transitImportErrorDuplicate), findsOneWidget);

  //   await tester.tap(find.byType(ExpansionTile).first);
  //   await tester.pump();

  //   findText('i1', 'stagedIng');
  //   findText('q1', 'stagedQua');
  //   findText('q2', 'stagedQua');

  //   await tester.tap(find.text('Save'));
  //   await tester.pumpAndSettle();

  //   expect(Stock.instance.length, equals(1));
  //   expect(Quantities.instance.length, equals(2));
  //   expect(Menu.instance.length, equals(2));
  //   final pNames = Menu.instance.products.map((e) => e.name).toList();
  //   expect(pNames, equals(['p1', 'p2', 'p3']));
  //   final p1 = Menu.instance.getProductByName('p1');
  //   expect(p1?.length, equals(1));
  //   expect(p1?.getItemByName('i1')?.length, equals(2));
  // });

  // Future<void> prepareImport(
  //   WidgetTester tester,
  //   String name,
  //   int index,
  //   bool commit,
  //   List<List<Object>> data, [
  //   List<String>? names,
  // ]) async {
  //   when(cache.get(iCacheKey + '.$name')).thenReturn('title 1');
  //   final sheetsApi = getMockSheetsApi();
  //   mockSheetData(sheetsApi, data);

  //   await tester.pumpWidget(buildApp(sheetsApi));
  //   await tapBtn(tester, index);
  //   await tester.tap(find.text(S.transitImportPreviewBtn));
  //   await tester.pump();

  //   if (names == null) {
  //     for (var item in data) {
  //       findText(item[0] as String, 'staged');
  //     }
  //   } else {
  //     for (var item in names) {
  //       findText(item, 'staged');
  //     }
  //   }

  //   await tester.tap(commit ? find.text('Save') : find.byIcon(Icons.close));
  //   await tester.pumpAndSettle();
  // }

  // testWidgets('menu(abort)', (tester) async {
  //   await prepareImport(tester, 'menu', 0, false, [
  //     ['c1', 'p1', 1, 1, '- i1,1\n  + q1,1,1,1\n  + q2'],
  //   ]);

  //   expect(Stock.instance.isEmpty, isTrue);
  //   expect(Quantities.instance.isEmpty, isTrue);
  //   expect(Menu.instance.isEmpty, isTrue);
  //   expect(Stock.instance.stagedItems.isEmpty, isTrue);
  //   expect(Quantities.instance.stagedItems.isEmpty, isTrue);
  //   expect(Menu.instance.stagedItems.isEmpty, isTrue);
  // });

  // testWidgets('stock', (tester) async {
  //   Stock.instance.replaceItems({'i0': Ingredient(id: 'i0')});
  //   await prepareImport(tester, 'stock', 1, true, [
  //     ['i1', 1],
  //     ['i2'],
  //     ['i3', 1, 1, -2],
  //   ], [
  //     'i1',
  //     'i2'
  //   ]);

  //   // should not reset old value
  //   expect(Stock.instance.length, equals(3));
  //   expect(Stock.instance.getItem('i0'), isNotNull);
  //   expect(Stock.instance.getItemByName('i1'), isNotNull);
  // });

  // testWidgets('quantities', (tester) async {
  //   Quantities.instance.replaceItems({'q0': Quantity(id: 'q0')});
  //   await prepareImport(tester, 'quantities', 2, true, [
  //     ['q1', 2],
  //     ['q2'],
  //   ]);

  //   // should not reset old value
  //   expect(Quantities.instance.length, equals(3));
  //   expect(Quantities.instance.getItem('q0'), isNotNull);
  //   expect(Quantities.instance.getItemByName('q1'), isNotNull);
  // });

  // testWidgets('replenisher(commit)', (tester) async {
  //   await prepareImport(tester, 'replenisher', 3, true, [
  //     ['r1', '- i1,20\n- i2,-5'],
  //     ['r2'],
  //   ]);

  //   expect(Stock.instance.length, equals(2));
  //   expect(Stock.instance.getItemByName('i2'), isNotNull);
  //   expect(Replenisher.instance.length, equals(2));
  //   expect(Replenisher.instance.getItemByName('r1'), isNotNull);
  // });

  // testWidgets('replenisher(abort)', (tester) async {
  //   await prepareImport(tester, 'replenisher', 3, false, [
  //     ['r1', '- i1,20\n- i2,-5'],
  //     ['r2'],
  //   ]);

  //   expect(Stock.instance.isEmpty, isTrue);
  //   expect(Stock.instance.stagedItems.isEmpty, isTrue);
  //   expect(Replenisher.instance.isEmpty, isTrue);
  //   expect(Replenisher.instance.stagedItems.isEmpty, isTrue);
  // });

  // testWidgets('orderAttribute', (tester) async {
  //   await prepareImport(tester, 'orderAttr', 4, true, [
  //     ['c1', S.orderAttributeModeName('changeDiscount'), '- co1,true\n- co2,,5'],
  //     ['c2'],
  //   ]);

  //   verify(storage.reset(Stores.orderAttributes)).called(1);
  //   verify(storage.add(Stores.orderAttributes, any, any)).called(2);

  //   expect(OrderAttributes.instance.length, equals(2));

  //   final items = OrderAttributes.instance.itemList;
  //   expect(items[0].name, equals('c1'));
  //   expect(items[1].name, equals('c2'));

  //   final options = items.first.itemList;
  //   expect(options[0].name, equals('co1'));
  //   expect(options[1].name, equals('co2'));
  // });

  // testWidgets('menu + stock', (tester) async {
  //   when(cache.get(iCacheKey + '.stock')).thenReturn('stock 2');
  //   final sheetsApi = getMockSheetsApi();
  //   final data1 = [
  //     ['c1', 'p1', 1, 1, '- i1,1\n  + q1,1,1,1\n  + q2'],
  //   ];
  //   final data2 = [
  //     ['i1', 1],
  //     ['i2'],
  //     ['i3', -2],
  //   ];
  //   mockSheetData(sheetsApi, data1, 'title');
  //   mockSheetData(sheetsApi, data2, 'stock');

  //   await tester.pumpWidget(buildApp(sheetsApi));
  //   await tester.pumpAndSettle();
  //   await go2Importer(tester);

  //   await tester.tap(find.byKey(const Key('gs_export.import_all')));
  //   await tester.pumpAndSettle();
  //   await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
  //   await tester.pumpAndSettle();
  //   await tester.pumpAndSettle();

  //   // should not reset old value
  //   expect(Stock.instance.length, equals(2));
  //   expect(Stock.instance.getItemByName('i1'), isNotNull);
  //   expect(Menu.instance.length, equals(1));
  // });

  setUp(() {
    Menu();
    Stock();
    Quantities();
    OrderAttributes();
    Replenisher();
  });
}
