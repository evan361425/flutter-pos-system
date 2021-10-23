import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/ui/analysis/widgets/analysis_order_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../mocks/mock_cache.dart';

void main() {
  group('Analysis Order List', () {
    testWidgets('should not load when initialize', (tester) async {
      final orderListState = GlobalKey<AnalysisOrderListState>();

      var loadCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: AnalysisOrderList(
            key: orderListState,
            handleLoad: (_, __) {
              loadCount++;
              return Future.delayed(
                Duration(milliseconds: 100),
                () => Future.value([]),
              );
            }),
      ));

      expect(loadCount, equals(0));
      expect(find.byType(CircularLoading), findsNothing);
      expect(find.byType(SmartRefresher), findsNothing);

      orderListState.currentState?.reset({}, totalPrice: 0, totalCount: 0);

      await tester.pump(Duration(milliseconds: 10));

      expect(find.byType(CircularLoading), findsOneWidget);
      expect(loadCount, equals(1));

      await tester.pumpAndSettle();

      // should not set refresher if empty result
      expect(find.byType(SmartRefresher), findsNothing);
      expect(loadCount, equals(1));
    });

    testWidgets('should load more', (tester) async {
      final orderListState = GlobalKey<AnalysisOrderListState>();
      final data = [
        OrderObject.fromMap({'id': 1}),
        OrderObject.fromMap({'id': 2}),
      ];
      var loadCount = 0;

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: AnalysisOrderList(
              key: orderListState,
              handleLoad: (_, start) {
                loadCount++;
                return Future.value(
                  start == data.length ? [] : data.sublist(start, start + 1),
                );
              }),
        ),
      ));

      orderListState.currentState?.reset({}, totalPrice: 0, totalCount: 0);
      await tester.pumpAndSettle();

      expect(loadCount, equals(1));
      expect(find.byType(SmartRefresher), findsOneWidget);

      final center = tester.getCenter(find.byType(SmartRefresher));

      await tester.dragFrom(center, Offset(0, -300));
      await tester.pumpAndSettle();

      expect(loadCount, equals(2));

      await tester.dragFrom(center, Offset(0, -300));
      await tester.pumpAndSettle();

      expect(loadCount, equals(3));

      await tester.dragFrom(center, Offset(0, -300));
      await tester.pumpAndSettle();

      expect(loadCount, equals(3));
    });

    testWidgets('should navigate to modal', (tester) async {
      final orderListState = GlobalKey<AnalysisOrderListState>();
      final customerSettings = CustomerSettings();
      final customerSetting = CustomerSetting();
      final product = OrderProductObject(
          singlePrice: 1,
          originalPrice: 2,
          count: 3,
          productId: 'p-1',
          productName: 'p-1',
          isDiscount: true,
          ingredients: {
            'i-1': OrderIngredientObject(
                id: 'i-1',
                name: 'i-1',
                additionalPrice: 2,
                additionalCost: 1,
                amount: 3,
                quantityId: 'q-1',
                quantityName: 'q-1')
          });
      final order = OrderObject.fromMap({
        'id': 1,
        'encodedProducts': '[${jsonEncode(product.toMap())}]',
        'combination': '1:2,2:3',
      });

      customerSetting.replaceItems({'3': CustomerSettingOption()});
      customerSettings.replaceItems({
        '1': CustomerSetting(),
        '2': customerSetting,
      });

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: AnalysisOrderList(
              key: orderListState,
              handleLoad: (_, __) => Future.value(<OrderObject>[order])),
        ),
      ));

      orderListState.currentState?.reset({}, totalPrice: 0, totalCount: 0);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('analysis.order_list.1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(KIcons.back));
      await tester.pumpAndSettle();
    });

    setUp(() async {
      final currency = CurrencyProvider();
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
      LOG_LEVEL = 0;
      await currency.setCurrency(CurrencyTypes.TWD);
    });

    setUpAll(() {
      initializeCache();
    });
  });
}
