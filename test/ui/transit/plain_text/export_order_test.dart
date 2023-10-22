import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/ui/transit/transit_station.dart';
import 'package:possystem/ui/transit/plain_text_widgets/views.dart';

import '../../../mocks/mock_database.dart';
import '../../../mocks/mock_storage.dart';
import '../../../test_helpers/order_setter.dart';
import '../../../test_helpers/translator.dart';
import 'export_basic_test.dart';

void main() {
  group('Transit - Plain Text - Export Order', () {
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

    testWidgets('preview and export', (tester) async {
      final order = OrderSetter.sample();
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);

      const message = '共 40 元，其中的 20 元是產品價錢。\n'
          '付額 0 元、成分 30 元。\n'
          '顧客的 oa-1 為 oao-1、oa-2 為 oao-2。\n'
          '餐點有 10 份（2 種）包括：\n'
          'p-1（c-1）5 份共 35 元成份包括 i-1（q-1，使用 3 個）、i-2（預設份量）、i-3（預設份量，使用 -5 個）；\n'
          'p-2（c-2）15 份共 300 元沒有設定成分。';

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      OrderSetter.setOrder(order);
      await tester.tap(find.byIcon(Icons.expand_outlined));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      OrderSetter.setDetailedOrders([order]);
      await tester.tap(find.byKey(const Key('export_btn')));
      await tester.pumpAndSettle();

      final copied = await Clipboard.getData('text/plain');
      expect(
        copied?.text,
        equals('3月4日 05:06:07\n$message'),
      );
    });

    test('format', () {
      const expected = '共 0 元。\n'
          '付額 0 元、成分 0 元。\n'
          '餐點有 0 份包括：\n。';

      final actual = ExportOrderView.formatOrder(
        OrderObject(createdAt: DateTime.now()),
      );

      expect(actual, equals(expected));
    });

    setUpAll(() {
      initializeTranslator();
      initializeDatabase();
      initializeStorage();
      // init dependencies
      CurrencySetting().isInt = true;
    });
  });
}
