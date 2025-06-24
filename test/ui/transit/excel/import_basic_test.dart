import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/plain_text_exporter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/transit_station.dart';

import '../../../mocks/mock_storage.dart';
import '../../../test_helpers/file_mocker.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - Excel - Import Basic', () {
    Widget buildApp() {
      return const MaterialApp(
        home: TransitStation(
          exporter: PlainTextExporter(),
          catalog: TransitCatalog.importModel,
          method: TransitMethod.excel,
        ),
      );
    }

    testWidgets('successfully', (tester) async {
      final picker = mockFilePicker();

      final excel = Excel.createExcel();
      final sheet = excel[FormattableModel.quantities.l10nName];
      sheet.appendRow([TextCellValue('name'), TextCellValue('defaultProportion')]);
      sheet.appendRow([TextCellValue('q1'), const IntCellValue(1)]);
      mockFilePick(picker, bytes: excel.encode());

      Quantities.instance.replaceItems({'q1': Quantity(id: 'q1', name: 'q1')});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.model_picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.model_picker.quantities')), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.file_present_sharp));
      await tester.pumpAndSettle();

      // allow import
      await tester.tap(find.byKey(const Key('transit.import.confirm')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
      await tester.pumpAndSettle();

      verify(storage.add(any, any, {'name': 'q1', 'defaultProportion': 1}));
    });

    testWidgets('abort picking', (tester) async {
      final picker = mockFilePicker();
      mockFilePick(picker);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.file_present_sharp));
      await tester.pumpAndSettle();

      expect(find.text(S.transitImportErrorExcelPickFile), findsOneWidget);
    });

    setUpAll(() {
      initializeTranslator();
      initializeStorage();
      initializeFileSystem();
    });

    setUp(() {
      Menu();
      Stock();
      Quantities();
      Replenisher();
      OrderAttributes();
    });
  });
}
