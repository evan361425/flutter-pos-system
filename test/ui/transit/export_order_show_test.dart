import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/ui/transit/order_list_view.dart';

import '../../mocks/mock_database.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Export Order Loader Memory Info', () {
    void setLoader(int memory) {
      final map = OrderObject(products: []).toMap();
      map['id'] = 1;
      when(database.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) => Future.value([map]));

      when(database.query(
        any,
        columns: anyNamed('columns'),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) => Future.value([
            {
              "totalPrice": 10,
              "count": 10,
              "productSize": memory,
              "attrSize": 10,
            }
          ]));
    }

    Future<void> showDialog(WidgetTester tester, IconData icon) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final range = DateTimeRange(start: yesterday, end: DateTime.now());
      final widget = OrderListView(
        notifier: ValueNotifier(range),
        formatOrder: (o) => const Text('hi'),
        memoryPredictor: (m) => m.productSize,
        warning: 'hi there',
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
    }

    testWidgets('show ok', (tester) async {
      setLoader(0);

      await showDialog(tester, Icons.check_outlined);

      expect(find.text('預估容量為：<1KB'), findsOneWidget);
    });

    testWidgets('show warning', (tester) async {
      setLoader(700 * 1024);

      await showDialog(tester, Icons.warning_amber_outlined);

      expect(find.text('預估容量為：700KB'), findsOneWidget);
    });

    testWidgets('show danger', (tester) async {
      setLoader((1.5 * 1024 * 1024).toInt());

      await showDialog(tester, Icons.dangerous_outlined);

      expect(find.text('預估容量為：1.5MB'), findsOneWidget);
    });

    setUpAll(() {
      initializeDatabase();
      initializeTranslator();

      CurrencySetting().isInt = true;
      Seller();
    });
  });
}
