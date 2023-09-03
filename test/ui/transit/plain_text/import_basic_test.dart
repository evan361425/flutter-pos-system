import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/transit_station.dart';

import '../../../mocks/mock_storage.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Plain Text Export Import Basic', () {
    Widget buildApp() {
      return const MaterialApp(
        home: TransitStation(
          exporter: PlainTextExporter(),
          type: TransitType.basic,
          method: TransitMethod.plainText,
        ),
      );
    }

    const message = '共設定 1 種份量\n\n第1種份量叫做 q1，預設會讓成分的份量乘以 1 倍。';

    testWidgets('wrong text', (tester) async {
      const warnMsg = '這段文字無法匹配相應的服務，請參考匯出時的文字內容';

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(Tab, S.btnImport));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('import_text')),
        'some-text',
      );
      await tester.tap(find.byKey(const Key('import_btn')));
      await tester.pumpAndSettle();

      expect(find.text(warnMsg), findsOneWidget);
    });

    testWidgets('successfully', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(Tab, S.btnImport));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('import_text')), message);
      await tester.tap(find.byKey(const Key('import_btn')));
      await tester.pumpAndSettle();

      // allow import
      await tester.tap(find.text(S.btnSave));
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
