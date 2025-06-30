import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/xfile.dart';
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
  group('Transit - Excel - Export Order', () {
    Widget buildApp() {
      return const MaterialApp(
        home: TransitStation(
          catalog: TransitCatalog.exportOrder,
          method: TransitMethod.excel,
        ),
      );
    }

    testWidgets('preview and export', (tester) async {
      final picker = mockFilePicker();
      final path = mockFileSave(picker);
      when(cache.get('exporter_order_meta.withPrefix')).thenReturn(false);

      final order = OrderSetter.sample();
      OrderSetter.setMetrics([order], countingAll: true);
      OrderSetter.setOrders([order]);
      OrderSetter.setOrder(order);
      OrderSetter.setDetailedOrders([order]);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.order_export')));
      await tester.pumpAndSettle();

      expect(find.text(S.transitExportOrderSuccessExcel), findsOneWidget);
      verify(picker.saveFile(
        dialogTitle: anyNamed('dialogTitle'),
        fileName: '${S.transitExportOrderFileName}.xlsx',
        bytes: anyNamed('bytes'),
      ));

      final excel = Excel.decodeBytes(XFile('$path/${S.transitExportOrderFileName}.xlsx').file.readAsBytesSync());
      expect(excel.sheets.keys.toList(), equals(FormattableOrder.values.map((e) => e.l10nName).toList()));
    });

    setUp(() {
      reset(cache);
      when(cache.get(any)).thenReturn(null);
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
