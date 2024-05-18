import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/translator.dart';
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
          catalog: TransitCatalog.order,
          method: TransitMethod.plainText,
        ),
      );
    }

    testWidgets('preview and export', (tester) async {
      final order = OrderSetter.sample();
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);

//       const message = '''Total price \$40, 20 of them are product price.
// Paid \$0, cost \$30.
// Customer's oa-1 is oao-1、oa-2 is oao-2.
// There are 10 products (2 types of set) including:
// 5 of p-1 (c-1), total price is \$35, ingredients are i-1 (q-1), used 3、i-2 (default quantity)、i-3 (default quantity), used -5；
// 15 of p-2 (c-2), total price is \$300, no ingredient settings.
// ''';
      final message = [
        S.transitPTFormatOrderPrice(1, '40', '20'),
        S.transitPTFormatOrderMoney('0', '30'),
        S.transitPTFormatOrderOrderAttribute([
          S.transitPTFormatOrderOrderAttributeItem('oa-1', 'oao-1'),
          S.transitPTFormatOrderOrderAttributeItem('oa-2', 'oao-2'),
        ].join('、')),
        S.transitPTFormatOrderProductCount(
            10,
            2,
            [
              S.transitPTFormatOrderProduct(
                  1,
                  'p-1',
                  'c-1',
                  5,
                  '35',
                  [
                    S.transitPTFormatOrderIngredient(3, 'i-1', 'q-1'),
                    S.transitPTFormatOrderIngredient(0, 'i-2', S.transitPTFormatOrderNoQuantity),
                    S.transitPTFormatOrderIngredient(-5, 'i-3', S.transitPTFormatOrderNoQuantity),
                  ].join('、')),
              S.transitPTFormatOrderProduct(0, 'p-2', 'c-2', 15, '300', ''),
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
      await tester.tap(find.byKey(const Key('export_btn')));
      await tester.pumpAndSettle();

      final copied = await Clipboard.getData('text/plain');

      expect(
        copied?.text,
        equals([S.transitOrderItemTitle(order.createdAt), message].join('\n')),
      );
    });

    test('format', () {
//       const expected = '''Total price \$0.
// Paid \$0, cost \$0.
// There is no product.''';
      final expected = [
        S.transitPTFormatOrderPrice(0, '0', '0'),
        S.transitPTFormatOrderMoney('0', '0'),
        S.transitPTFormatOrderProductCount(0, 0, ''),
      ].join('\n');

      final actual = ExportOrderView.formatOrder(
        OrderObject(createdAt: DateTime.now()),
      );

      expect(actual, equals(expected));
    });

    setUpAll(() {
      initializeTranslator();
      initializeDatabase();
      initializeStorage();
    });
  });
}
