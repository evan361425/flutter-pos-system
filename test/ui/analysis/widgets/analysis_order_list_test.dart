import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/analysis_order_list.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_database.dart';
import '../../../mocks/mock_storage.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Analysis Order List', () {
    Widget buildApp(Widget home) {
      when(cache.get(any)).thenReturn(null);
      return ChangeNotifierProvider.value(
        value: SettingsProvider([CurrencySetting()]),
        child: MaterialApp(home: home),
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

    testWidgets('should show progress when initializing', (tester) async {
      var loadCount = 0;

      setLoader(() {
        loadCount++;
        return Future.delayed(
          const Duration(milliseconds: 100),
          () => Future.value([]),
        );
      });

      await tester.pumpWidget(buildApp(
        AnalysisOrderList(notifier: ValueNotifier(Util.getDateRange())),
      ));
      await tester.pump(const Duration(milliseconds: 10));

      expect(find.byType(CircularLoading), findsOneWidget);
      expect(loadCount, equals(1));

      await tester.pumpAndSettle();

      // should not set progress if empty result
      expect(find.byType(CircularLoading), findsNothing);
      expect(find.text('查無點餐紀錄'), findsOneWidget);
      expect(loadCount, equals(1));
    });

    testWidgets('should load more and refresh', (tester) async {
      final data = List<Map<String, int>>.generate(21, (i) => {"id": i});
      final notifier = ValueNotifier(Util.getDateRange());
      var loadCount = 0;

      setLoader(() => Future.value(loadCount * 10 > data.length
          ? <Map<String, int>>[]
          : data.sublist(
              loadCount++ * 10,
              min(loadCount * 10, data.length),
            )));

      await tester.pumpWidget(buildApp(
        Material(child: AnalysisOrderList(notifier: notifier)),
      ));
      await tester.pumpAndSettle();

      expect(loadCount, equals(2));

      final center = tester.getCenter(find.byKey(const Key('item_loader')));

      await tester.dragFrom(center, const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(loadCount, equals(3));

      // touch limit and finish loading
      await tester.dragFrom(center, const Offset(0, -1000));
      await tester.pumpAndSettle();

      expect(loadCount, equals(3));

      // reset range
      loadCount = 0;
      notifier.value = Util.getDateRange(days: 2);
      await tester.pumpAndSettle();

      expect(loadCount, equals(2));
    });

    OrderObject getOrder() {
      final stock = Stock();
      stock.replaceItems({
        'i-1': Ingredient(id: 'i-1', name: 'i-1'),
        'i-2': Ingredient(id: 'i-2', name: 'i-2'),
        'i-3': Ingredient(id: 'i-3', name: 'i-3'),
      });
      final product = OrderProductObject(
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
        'encodedProducts': '[${jsonEncode(product.toMap())}]',
        'encodedAttributes': jsonEncode([
          OrderSelectedAttributeObject.fromId('1', '3').toMap(),
          OrderSelectedAttributeObject.fromId('2', '4').toMap(),
        ]),
      });
    }

    Map<String, Object?> getOrderMap() {
      final map = getOrder().toMap();
      map['id'] = 1;
      return map;
    }

    testWidgets('should navigate to modal', (tester) async {
      setLoader(() {
        final o = getOrder();
        final products = o.products.toList();
        products.add(const OrderProductObject(
          productId: 'p-2',
          productName: 'p-2',
          catalogName: 'c-2',
          count: 1,
          cost: 10,
          singlePrice: 20,
          originalPrice: 30,
          isDiscount: false,
          ingredients: [],
        ));
        final order = OrderObject(
          products: products,
          totalPrice: 47,
          totalCount: 2,
          attributes: o.attributes,
        );
        final map = order.toMap();
        map['id'] = 1;
        return Future.value([map]);
      });

      await tester.pumpWidget(buildApp(Material(
        child: AnalysisOrderList(notifier: ValueNotifier(Util.getDateRange())),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('analysis.order_list.1')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const Key('order_cashier_product_list.attributes')));
      await tester.pumpAndSettle();

      expect(find.text('Test attr'), findsOneWidget);
      expect(find.text('Test opt'), findsOneWidget);

      await tester.tap(find.byIcon(KIcons.back));
      await tester.pumpAndSettle();

      expect(find.text('p-2'), findsOneWidget);
    });

    testWidgets('should delete order', (tester) async {
      when(database.delete(any, 1)).thenAnswer((_) => Future.value());
      setLoader(() => Future.value([getOrderMap()]));

      await tester.pumpWidget(buildApp(Material(
        child: AnalysisOrderList(notifier: ValueNotifier(Util.getDateRange())),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('analysis.order_list.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('analysis.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn.delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      verify(database.delete(any, any));
    });

    testWidgets('should delete order with other', (tester) async {
      when(database.delete(any, 1)).thenAnswer((_) => Future.value());

      // set up cashier
      CurrencySetting();
      final cashier = Cashier();
      await cashier.setCurrent([
        {'unit': 1, 'count': 10},
        {'unit': 5, 'count': 0},
        {'unit': 10, 'count': 10},
      ]);

      // order
      setLoader(() => Future.value([getOrderMap()]));

      await tester.pumpWidget(buildApp(Material(
        child: AnalysisOrderList(notifier: ValueNotifier(Util.getDateRange())),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('analysis.order_list.1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('analysis.more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn.delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('analysis.tile_del_with_other')));
      await tester.pumpAndSettle();

      expect(find.text('i-1 將增加 3 單位'), findsOneWidget);
      expect(find.text('i-3 將減少 5 單位'), findsOneWidget);
      expect(find.text('10 元將減少 4 個至 6 個'), findsOneWidget);
      expect(find.text('1 元將減少 7 個至 3 個'), findsOneWidget);
      expect(find.text('收銀機要用小錢換才能滿足。'), findsOneWidget);

      // Reset current money for other branch
      await cashier.setCurrent([
        {'unit': 1, 'count': 5},
        {'unit': 10, 'count': 10},
      ]);
      await tester.tap(find.byKey(const Key('analysis.tile_del_with_other')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('analysis.tile_del_with_other')));
      await tester.pumpAndSettle();

      expect(find.text('10 元將減少 4 個至 6 個'), findsOneWidget);
      expect(find.text('1 元將減少 5 個至 0 個'), findsOneWidget);
      expect(find.text('收銀機將不夠錢換，不管了。'), findsOneWidget);

      // Reset current money for other branch
      await cashier.setCurrent([
        {'unit': 1, 'count': 10},
        {'unit': 10, 'count': 10},
      ]);
      await tester.tap(find.byKey(const Key('analysis.tile_del_with_other')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('analysis.tile_del_with_other')));
      await tester.pumpAndSettle();

      expect(find.text('1 元將減少 7 個至 3 個'), findsOneWidget);
      expect(find.text('收銀機將不夠錢換，不管了。'), findsNothing);

      when(storage.set(Stores.stock, any)).thenAnswer((_) => Future.value());
      when(storage.set(Stores.cashier, any)).thenAnswer((_) => Future.value());

      await tester.tap(find.byKey(const Key('delete_dialog.confirm')));
      await tester.pumpAndSettle();

      verify(storage.set(Stores.stock, any));
      verify(storage.set(Stores.cashier, any));
    });

    testWidgets('should navigate to exporter', (tester) async {
      setLoader(() => Future.value([getOrderMap()]));

      await tester.pumpWidget(buildApp(Material(
        child: AnalysisOrderList(notifier: ValueNotifier(Util.getDateRange())),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('analysis.export')));
      await tester.pumpAndSettle();
      // dropdown have multiple child for items
      await tester.tap(find.text(S.exporterTypes('plainText')).last);
      await tester.pumpAndSettle();

      expect(find.text(S.exporterTypes('plainText')), findsOneWidget);
    });

    setUpAll(() {
      initializeCache();
      initializeTranslator();
      initializeDatabase();
      initializeStorage();
      // init seller
      Seller();
      Menu();
    });
  });
}
