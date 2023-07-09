// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/sheets/v4.dart' as gs;
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/language_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/exporter/exporter_routes.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/order_formatter.dart';
import 'package:possystem/ui/exporter/google_sheet_widgets/order_properties_modal.dart';
import 'package:possystem/ui/exporter/order_range_info.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_auth.dart';
import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_database.dart';
import '../../../mocks/mock_google_api.dart';
import '../../../services/auth_test.mocks.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Google Sheet Exporter Export Order', () {
    const cacheKey = 'exporter_order_google_sheet';
    const gsExporterScopes = [
      gs.SheetsApi.driveFileScope,
      gs.SheetsApi.spreadsheetsScope
    ];

    Widget buildApp([CustomMockSheetsApi? sheetsApi]) {
      return MaterialApp(
        home: ExporterStation(
          info: ExporterInfoType.order,
          method: ExportMethod.googleSheet,
          exporter: GoogleSheetExporter(
            sheetsApi: sheetsApi,
            scopes: gsExporterScopes,
          ),
        ),
      );
    }

    void setLoader(Future<List<Map<String, Object?>>> Function() cb) {
      when(database.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) => cb());

      when(database.query(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([{}]));
    }

    OrderObject getOrder() {
      final stock = Stock();
      stock.replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1'),
        'i-2': Ingredient(id: 'i-2', name: 'i-2'),
        'i-3': Ingredient(id: 'i-3', name: 'i-3'),
      });
      final p1 = OrderProductObject(
          singlePrice: 1,
          originalPrice: 2,
          count: 3,
          cost: 1,
          productId: 'p-1',
          productName: 'p-1',
          catalogName: 'c-1',
          isDiscount: true,
          ingredients: [
            OrderIngredientObject(
                id: 'i-1',
                name: 'i-1',
                productIngredientId: 'pi-1',
                additionalPrice: 2,
                additionalCost: 1,
                amount: 3,
                quantityId: 'q-1',
                productQuantityId: 'pq-1',
                quantityName: 'q-1'),
            OrderIngredientObject(
                id: 'i-2', name: 'i-2', productIngredientId: 'pi-1', amount: 0),
            OrderIngredientObject(
              id: 'i-3',
              name: 'i-3',
              productIngredientId: 'pi-1',
              amount: -5,
            ),
          ]);
      const p2 = OrderProductObject(
        productId: 'p-2',
        productName: 'p-2',
        catalogName: 'c-2',
        count: 1,
        cost: 10,
        singlePrice: 20,
        originalPrice: 30,
        isDiscount: false,
        ingredients: [],
      );

      OrderAttributes().replaceItems({
        '1': OrderAttribute(id: '1', name: 'Test attr')
          ..replaceItems({'3': OrderAttributeOption(id: '3', name: 'Test opt')})
          ..prepareItem(),
        '2': OrderAttribute(id: '2', mode: OrderAttributeMode.changeDiscount)
          ..replaceItems({'4': OrderAttributeOption(id: '4', modeValue: 10)})
          ..prepareItem(),
      });

      return OrderObject.fromMap({
        'id': 1,
        'totalPrice': 47,
        'productsPrice': 20,
        'createdAt':
            DateTime(2023, 3, 4, 5, 6, 7, 8, 9).millisecondsSinceEpoch ~/ 1000,
        'encodedProducts': jsonEncode([p1.toMap(), p2.toMap()]),
        'encodedAttributes': jsonEncode([
          OrderSelectedAttributeObject.fromId('1', '3').toMap(),
          OrderSelectedAttributeObject.fromId('2', '4').toMap(),
        ]),
      });
    }

    testWidgets('#preview', (tester) async {
      setLoader(() => Future.value([
            getOrder().toMap()..addAll({'id': 1})
          ]));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.expand_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(Table), findsNWidgets(4));
    });

    testWidgets('#pick_range', (tester) async {
      setLoader(() => Future.value([]));
      final lang = LanguageSetting();
      final settings = SettingsProvider([lang]);
      lang.value = const Locale('en', 'US');
      final init = DateTimeRange(
        start: DateTime(2023, DateTime.june, 10),
        end: DateTime(2023, DateTime.june, 11),
      );

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
        ],
        child: MaterialApp(
          locale: lang.value,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          supportedLocales: [lang.value],
          home: ExporterStation(
            info: ExporterInfoType.order,
            method: ExportMethod.googleSheet,
            range: init,
            exporter: GoogleSheetExporter(
              scopes: gsExporterScopes,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn.edit_range')));
      await tester.pumpAndSettle();

      // xx/01-xx/05
      await tester.tap(find.text('1').first);
      await tester.tap(find.text('5').first);
      await tester.tap(find.text('SAVE')); // material 2
      await tester.pumpAndSettle();

      final expected = DateTimeRange(
        start: DateTime(2023, DateTime.june, 1),
        end: DateTime(2023, DateTime.june, 6),
      );

      expect(
        find.text('${expected.format(DateFormat.MMMd('zh'))} 的訂單'),
        findsOneWidget,
      );
    });

    group('#export', () {
      testWidgets('create and overwrite', (tester) async {
        final order = getOrder();
        final sheetsApi = getMockSheetsApi();
        final today = DateFormat('MMdd').format(DateTime.now());
        setLoader(() => Future.value([
              order.toMap()..addAll({'id': 1})
            ]));
        when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
        when(sheetsApi.spreadsheets.create(
          any,
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(gs.Spreadsheet(
              spreadsheetId: 'abc',
              sheets: OrderSheetType.values.map((e) {
                return gs.Sheet(
                  properties: gs.SheetProperties(
                    sheetId: e.index,
                    title: '$today ${S.exporterTypeName(e.name)}',
                  ),
                );
              }).toList(),
            )));
        when(sheetsApi.spreadsheets.batchUpdate(
          any,
          any,
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(gs.BatchUpdateSpreadsheetResponse()));

        await tester.pumpWidget(buildApp(sheetsApi));
        await tester.pumpAndSettle();
        await tester.tap(find.text('建立匯出'));
        await tester.pumpAndSettle();

        final title = S.exporterOrderTitle;
        verify(cache.set(cacheKey, 'abc:true:' + title));

        final expected = [
          [
            OrderFormatter.orderHeaders,
            ...OrderFormatter.formatOrder(order),
          ],
          [
            OrderFormatter.orderSetAttrHeaders,
            ...OrderFormatter.formatOrderSetAttr(order),
          ],
          [
            OrderFormatter.orderProductHeaders,
            ...OrderFormatter.formatOrderProduct(order),
          ],
          [
            OrderFormatter.orderIngredientHeaders,
            ...OrderFormatter.formatOrderIngredient(order),
          ],
        ];
        verify(sheetsApi.spreadsheets.batchUpdate(
          argThat(predicate<gs.BatchUpdateSpreadsheetRequest?>((batch) {
            for (var e1 in expected) {
              final req = batch?.requests?.removeAt(0);
              for (var e2 in e1) {
                final row = req?.updateCells?.rows?.removeAt(0);
                final cells = row?.values
                    ?.map((cell) => cell.userEnteredValue)
                    .map((cell) => cell?.stringValue ?? cell?.numberValue)
                    .toList();
                for (var e3 in e2) {
                  final cell = cells?.removeAt(0);
                  if (cell != e3) {
                    return false;
                  }
                }
              }
            }
            return true;
          })),
          any,
          $fields: anyNamed('\$fields'),
        ));
      });

      testWidgets('edit sheet name and append', (tester) async {
        final order = getOrder();
        final sheetsApi = getMockSheetsApi();
        setLoader(() => Future.value([
              order.toMap()..addAll({'id': 1})
            ]));

        when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
        // exist spreadsheet
        when(cache.get(cacheKey)).thenReturn('id:true:name');
        when(cache.get(cacheKey + '.order')).thenReturn('o title');
        when(cache.get(cacheKey + '.orderSetAttr')).thenReturn('os title');
        when(cache.get(cacheKey + '.orderProduct')).thenReturn('op title');
        when(cache.get(cacheKey + '.orderIngredient')).thenReturn('oi title');
        when(cache.get(cacheKey + '.order.required')).thenReturn(false);
        when(sheetsApi.spreadsheets.get(
          any,
          $fields: anyNamed('\$fields'),
          includeGridData: anyNamed('includeGridData'),
        )).thenAnswer((_) => Future.value(
              gs.Spreadsheet(
                  sheets: ['o', 'os', 'op', 'oi']
                      .map((e) => gs.Sheet(
                          properties: gs.SheetProperties(
                              title: '$e title', sheetId: 1)))
                      .toList()),
            ));
        when(sheetsApi.spreadsheets.batchUpdate(
          any,
          any,
          $fields: anyNamed('\$fields'),
        )).thenAnswer((_) => Future.value(gs.BatchUpdateSpreadsheetResponse()));

        await tester.pumpWidget(buildApp(sheetsApi));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('edit_sheets')));
        await tester.pumpAndSettle();
        // disable it
        await tester.tap(find.byKey(const Key('is_overwrite')));
        await tester.pumpAndSettle();
        // disable it
        await tester.tap(find.byKey(const Key('with_prefix')));
        await tester.pumpAndSettle();
        // save it
        await tester.tap(find.byKey(const Key('modal.save')));
        await tester.pumpAndSettle();

        verify(cache.set(cacheKey + '.isOverwrite', false));
        verify(cache.set(cacheKey + '.withPrefix', false));
        verify(cache.set(cacheKey + '.order', 'o title'));
        verify(cache.set(cacheKey + '.order.required', false));

        // export
        await tester.tap(find.text('指定匯出'));
        await tester.pumpAndSettle();

        final expected = [
          OrderFormatter.formatOrderSetAttr(order),
          OrderFormatter.formatOrderProduct(order),
          OrderFormatter.formatOrderIngredient(order),
        ];
        verify(sheetsApi.spreadsheets.batchUpdate(
          argThat(predicate<gs.BatchUpdateSpreadsheetRequest?>((batch) {
            for (var e1 in expected) {
              final req = batch?.requests?.removeAt(0);
              for (var e2 in e1) {
                final row = req?.appendCells?.rows?.removeAt(0);
                final cells = row?.values
                    ?.map((cell) => cell.userEnteredValue)
                    .map((cell) => cell?.stringValue ?? cell?.numberValue)
                    .toList();
                for (var e3 in e2) {
                  final cell = cells?.removeAt(0);
                  if (cell != e3) {
                    return false;
                  }
                }
              }
            }
            return true;
          })),
          any,
          $fields: anyNamed('\$fields'),
        ));
      });
    });

    setUp(() {
      when(cache.get(any)).thenReturn(null);
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(MockUser()));
    });

    setUpAll(() {
      initializeCache();
      initializeTranslator();
      initializeDatabase();
      initializeAuth();
      // init dependencies
      CurrencySetting().isInt = true;
      Seller();
    });
  });
}
