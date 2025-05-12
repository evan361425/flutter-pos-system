import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/plain_text_exporter.dart';
import 'package:possystem/ui/transit/plain_text/views.dart';
import 'package:possystem/ui/transit/transit_station.dart';

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
        .setMockMethodCallHandler(SystemChannels.platform, mockClipboard.handleMethodCall);

    Widget buildApp() {
      return const MaterialApp(
        home: TransitStation(
          exporter: PlainTextExporter(),
          catalog: TransitCatalog.exportOrder,
          method: TransitMethod.plainText,
        ),
      );
    }

    testWidgets('preview and export', (tester) async {
      final order = OrderSetter.sample();
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);

      final message = [
        S.transitFormatTextOrderPrice(1, '40', '20'),
        S.transitFormatTextOrderMoney('0', '30'),
        S.transitFormatTextOrderOrderAttribute([
          S.transitFormatTextOrderOrderAttributeItem('oa-1', 'oao-1'),
          S.transitFormatTextOrderOrderAttributeItem('oa-2', 'oao-2'),
        ].join('、')),
        S.transitFormatTextOrderProductCount(
            10,
            2,
            [
              S.transitFormatTextOrderProduct(
                  1,
                  'p-1',
                  'c-1',
                  5,
                  '35',
                  [
                    S.transitFormatTextOrderIngredient(3, 'i-1', 'q-1'),
                    S.transitFormatTextOrderIngredient(0, 'i-2', S.transitFormatTextOrderNoQuantity),
                    S.transitFormatTextOrderIngredient(-5, 'i-3', S.transitFormatTextOrderNoQuantity),
                  ].join('、')),
              S.transitFormatTextOrderProduct(0, 'p-2', 'c-2', 15, '300', ''),
            ].join('；\n')),
      ].join('\n');

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      OrderSetter.setOrder(order);
      await tester.tap(find.byIcon(Icons.expand_outlined));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      OrderSetter.setDetailedOrders([order]);
      await tester.tap(find.byKey(const Key('transit.order.export')));
      await tester.pumpAndSettle();

      final copied = await Clipboard.getData('text/plain');

      expect(
        copied?.text,
        equals([S.transitOrderItemTitle(order.createdAt), message].join('\n')),
      );
    });

    test('format', () {
      final expected = [
        S.transitFormatTextOrderPrice(0, '0', '0'),
        S.transitFormatTextOrderMoney('0', '0'),
        S.transitFormatTextOrderProductCount(0, 0, ''),
      ].join('\n');

      final actual = ExportOrderView.formatOrder(OrderObject(createdAt: DateTime.now()));

      expect(actual, equals(expected));
    });

    setUpAll(() {
      initializeTranslator();
      initializeDatabase();
      initializeStorage();
    });
  });
}
