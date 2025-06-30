import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/exporter/plain_text_exporter.dart';
import 'package:possystem/ui/transit/transit_station.dart';

import '../../../mocks/mock_storage.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - Plain Text - Import Basic', () {
    Widget buildApp() {
      return const MaterialApp(
        home: TransitStation(
          exporter: PlainTextExporter(),
          catalog: TransitCatalog.importModel,
          method: TransitMethod.plainText,
        ),
      );
    }

    testWidgets('wrong text', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.transitImportBtnPlainTextAction));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('transit.pt_text')), 'some-text');
      await tester.tap(find.byKey(const Key('transit.pt_preview')));
      await tester.pumpAndSettle();

      expect(find.text(S.transitImportErrorPlainTextNotFound), findsOneWidget);
    });

    testWidgets('successfully', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text(S.transitImportBtnPlainTextAction));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('transit.pt_text')),
          '${S.transitFormatTextQuantitiesHeader(1)}\n\n'
          '${S.transitFormatTextQuantitiesQuantity('1', 'q1', '1')}');
      await tester.tap(find.byKey(const Key('transit.pt_preview')));
      await tester.pumpAndSettle();

      // allow import
      await tester.tap(find.byKey(const Key('transit.import.confirm')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_dialog.confirm')));
      await tester.pumpAndSettle();

      // quantities won't reset to avoid changing menu settings.
      verifyNever(storage.reset(any));
      verify(storage.add(any, any, {'name': 'q1', 'defaultProportion': 1}));
    });

    setUpAll(() {
      initializeTranslator();
      initializeStorage();
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
