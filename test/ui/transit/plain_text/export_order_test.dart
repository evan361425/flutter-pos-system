import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/ui/transit/transit_station.dart';
import 'package:possystem/ui/transit/plain_text_widgets/views.dart';

import '../../../mocks/mock_database.dart';
import '../../../mocks/mock_storage.dart';
import '../../../test_helpers/translator.dart';
import 'export_basic_test.dart';

void main() {
  group('Plain Text Export Export Basic', () {
    final mockClipboard = MockClipboard();
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(
            SystemChannels.platform, mockClipboard.handleMethodCall);

    Widget buildApp() {
      return const MaterialApp(
        home: TransitStation(
          exporter: PlainTextExporter(),
          type: TransitType.order,
          method: TransitMethod.plainText,
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

    Map<String, Object?> getOrder({int productsPrice = 20}) {
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

      final map = OrderObject.fromMap({
        'id': 1,
        'totalPrice': 47,
        'productsPrice': productsPrice,
        'createdAt':
            DateTime(2023, 3, 4, 5, 6, 7, 8, 9).millisecondsSinceEpoch ~/ 1000,
        'encodedProducts': jsonEncode([p1.toMap(), p2.toMap()]),
        'encodedAttributes': jsonEncode([
          OrderSelectedAttributeObject.fromId('1', '3').toMap(),
          OrderSelectedAttributeObject.fromId('2', '4').toMap(),
        ]),
      }).toMap();
      map['id'] = 1;
      return map;
    }

    testWidgets('preview and export', (tester) async {
      setLoader(() => Future.value([getOrder()]));
      const message = '共 47 元，其中的 20 元是產品價錢。\n'
          '付額 0 元、成分 13 元\n'
          '顧客的Test attr為Test opt、order attribute為order attribute option。\n'
          '餐點有 0 份（2 種）包括：\n'
          'p-1（c-1）3 份共 3 元成份包括 i-1（q-1，使用 3 個）、 i-2（預設份量）、 i-3（預設份量，使用 -5 個）；\n'
          'p-2（c-2）1 份共 20 元沒有設定成分。';

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.expand_outlined));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('export_btn')));
      await tester.pumpAndSettle();

      final copied = await Clipboard.getData('text/plain');
      expect(
        copied?.text,
        equals('3月4日 05:06:07\n$message'),
      );
    });

    test('format', () {
      const expected = '共 0 元\n'
          '付額 0 元、成分 0 元\n'
          '餐點有 0 份包括：\n。';

      final actual = ExportOrderView.formatOrder(OrderObject(products: []));

      expect(actual, equals(expected));
    });

    setUpAll(() {
      initializeTranslator();
      initializeDatabase();
      initializeStorage();
      // init dependencies
      CurrencySetting().isInt = true;
      Seller();
    });
  });
}
