import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/ui/analysis/widgets/analysis_order_list.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../mocks/mock_cache.dart';
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

    testWidgets('should not load when initialize', (tester) async {
      final orderListState = GlobalKey<AnalysisOrderListState>();

      var loadCount = 0;

      await tester.pumpWidget(buildApp(AnalysisOrderList(
          key: orderListState,
          handleLoad: (_, __) {
            loadCount++;
            return Future.delayed(
              const Duration(milliseconds: 100),
              () => Future.value([]),
            );
          })));

      expect(loadCount, equals(0));
      expect(find.byType(CircularLoading), findsNothing);
      expect(find.byType(SmartRefresher), findsNothing);

      orderListState.currentState?.reset({}, totalPrice: 0, totalCount: 0);

      await tester.pump(const Duration(milliseconds: 10));

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

      await tester.pumpWidget(buildApp(Material(
        child: AnalysisOrderList(
            key: orderListState,
            handleLoad: (_, start) {
              loadCount++;
              return Future.value(
                start == data.length ? [] : data.sublist(start, start + 1),
              );
            }),
      )));

      orderListState.currentState?.reset({}, totalPrice: 0, totalCount: 0);
      await tester.pumpAndSettle();

      expect(loadCount, equals(1));
      expect(find.byType(SmartRefresher), findsOneWidget);

      final center = tester.getCenter(find.byType(SmartRefresher));

      await tester.dragFrom(center, const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(loadCount, equals(2));

      await tester.dragFrom(center, const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(loadCount, equals(3));

      await tester.dragFrom(center, const Offset(0, -300));
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
                productIngredientId: 'pi-1',
                additionalPrice: 2,
                additionalCost: 1,
                amount: 3,
                quantityId: 'q-1',
                productQuantityId: 'pq-1',
                quantityName: 'q-1'),
            'i-2': OrderIngredientObject(
                id: 'i-2', name: 'i-2', productIngredientId: 'pi-1', amount: 0),
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

      await tester.pumpWidget(buildApp(Material(
        child: AnalysisOrderList(
            key: orderListState,
            handleLoad: (_, __) => Future.value(<OrderObject>[order])),
      )));

      orderListState.currentState?.reset({}, totalPrice: 0, totalCount: 0);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('analysis.order_list.1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(KIcons.back));
      await tester.pumpAndSettle();
    });

    setUpAll(() {
      initializeCache();
      initializeTranslator();
    });
  });
}
