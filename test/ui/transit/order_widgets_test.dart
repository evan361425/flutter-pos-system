import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/order_widgets.dart';

import '../../mocks/mock_database.dart';
import '../../test_helpers/order_setter.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Transit Order List', () {
    Future<void> showDialog(WidgetTester tester, IconData icon) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final range = DateTimeRange(start: yesterday, end: DateTime.now());
      final widget = _TestOrderList(ranger: ValueNotifier(range));

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
    }

    testWidgets('memory usage show ok', (tester) async {
      final order = OrderSetter.sample(price: 0);
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);

      await showDialog(tester, Icons.check_outlined);

      expect(find.text(S.transitOrderCapacityTitle('<1KB')), findsOneWidget);
    });

    testWidgets('memory usage show warning', (tester) async {
      final order = OrderSetter.sample(price: 700 * 1024);
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);

      await showDialog(tester, Icons.warning_amber_outlined);

      expect(find.text(S.transitOrderCapacityTitle('700KB')), findsOneWidget);
    });

    testWidgets('memory usage show danger', (tester) async {
      final order = OrderSetter.sample(price: 1.5 * 1024 * 1024);
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);

      await showDialog(tester, Icons.dangerous_outlined);

      expect(find.text(S.transitOrderCapacityTitle('1.5MB')), findsOneWidget);
    });

    testWidgets('preview order', (tester) async {
      final order = OrderSetter.sample();
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);
      OrderSetter.setOrder(order);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.expand_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(Table), findsNWidgets(4));
    });

    testWidgets('pick range', (tester) async {
      OrderSetter.setMetrics([], countingAll: true);
      OrderSetter.setOrders([]);

      final init = DateTimeRange(
        start: DateTime(2023, DateTime.june, 10),
        end: DateTime(2023, DateTime.june, 11),
      );

      await tester.pumpWidget(MaterialApp(
        locale: LanguageSetting.instance.language.locale,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: [LanguageSetting.instance.language.locale],
        home: TransitStation(
          catalog: TransitCatalog.exportOrder,
          method: TransitMethod.googleSheet,
          range: init,
          exporter: GoogleSheetExporter(
            scopes: gsExporterScopes,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn.edit_range')));
      await tester.pumpAndSettle();

      // xx/01-xx/05
      await tester.tap(find.text('1').first);
      await tester.tap(find.text('5').first);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final expected = DateTimeRange(
        start: DateTime(2023, DateTime.june, 1),
        end: DateTime(2023, DateTime.june, 6),
      );

      expect(
        find.text(S.transitOrderMetaRange(expected.format('en'))),
        findsOneWidget,
      );
    });

    setUpAll(() {
      initializeDatabase();
      initializeTranslator();
    });
  });
}

class _TestOrderList extends TransitOrderList {
  const _TestOrderList({required super.ranger});

  @override
  int memoryPredictor(OrderMetrics metrics) => _memoryPredictor(metrics);

  /// Offset are headers
  static int _memoryPredictor(OrderMetrics m) {
    return m.revenue.toInt();
  }
}
