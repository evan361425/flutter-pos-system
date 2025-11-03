import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/transit_station.dart';

import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_database.dart';
import '../../../mocks/mock_storage.dart';
import '../../../test_helpers/file_mocker.dart';
import '../../../test_helpers/order_setter.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - CSV - Export Order', () {
    Widget buildApp() {
      return const MaterialApp(
        home: TransitStation(
          catalog: TransitCatalog.exportOrder,
          method: TransitMethod.csv,
        ),
      );
    }

    testWidgets('preview and export', (tester) async {
      final picker = mockFilePicker();
      mockFileSave(picker);

      final order = OrderSetter.sample();
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);
      OrderSetter.setOrder(order);
      OrderSetter.setDetailedOrders([order]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.order_export')));
      await tester.pumpAndSettle();

      expect(find.text(S.transitExportOrderSuccessCsv), findsOneWidget);
      verify(picker.saveFile(
        dialogTitle: anyNamed('dialogTitle'),
        fileName: '${S.transitExportOrderFileName}.csv',
        bytes: argThat(predicate((e) {
          if (e is Uint8List) {
            final parts = utf8.decode(e).split('\n\n').toList();
            final expected = FormattableOrder.values.map((e) => e.formatHeader().join(','));

            return expected.mapIndexed((i, e) {
              return parts[i].split('\n').first == e;
            }).every((e) => e);
          }

          return false;
        }), named: 'bytes'),
      ));
    });

    testWidgets('export with custom columns', (tester) async {
      when(cache.get('exporter_order_meta.selectedColumns')).thenReturn([0, 2]); // basic and product only
      final picker = mockFilePicker();
      mockFileSave(picker);

      final order = OrderSetter.sample();
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);
      OrderSetter.setOrder(order);
      OrderSetter.setDetailedOrders([order]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.order_export')));
      await tester.pumpAndSettle();

      expect(find.text(S.transitExportOrderSuccessCsv), findsOneWidget);
      verify(picker.saveFile(
        dialogTitle: anyNamed('dialogTitle'),
        fileName: '${S.transitExportOrderFileName}.csv',
        bytes: argThat(predicate((e) {
          if (e is Uint8List) {
            final parts = utf8.decode(e).split('\n\n').toList();
            // Only basic and product columns should be exported
            final expected = [
              FormattableOrder.basic.formatHeader().join(','),
              FormattableOrder.product.formatHeader().join(','),
            ];

            return parts.length == 2 && expected.mapIndexed((i, e) {
              return parts[i].split('\n').first == e;
            }).every((e) => e);
          }

          return false;
        }), named: 'bytes'),
      ));
    });

    setUp(() {
      reset(cache);
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));
    });

    setUpAll(() {
      initializeTranslator();
      initializeDatabase();
      initializeStorage();
      initializeCache();
      initializeFileSystem();
    });
  });
}
