import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/helpers/exporter/plain_text_exporter.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/plain_text/views.dart' as pt;
import 'package:possystem/ui/transit/transit_station.dart';

import '../../../mocks/mock_storage.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - Plain Text - Export Basic', () {
    final MockClipboard mockClipboard = MockClipboard();
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, mockClipboard.handleMethodCall);

    Widget buildApp() {
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const TransitStation(
              exporter: PlainTextExporter(),
              catalog: TransitCatalog.model,
              method: TransitMethod.plainText,
            ),
          ),
        ]),
      );
    }

    test('test key attribute exist', () {
      var i = 1;
      pt.ExportBasicView(key: Key('test.${i++}'));
      pt.ImportBasicView(key: Key('test.${i++}'));
    });

    testWidgets('successfully', (tester) async {
      Quantities.instance.replaceItems({'q1': Quantity(id: 'q1', name: 'q1')});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tab.quantities')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('export_btn.quantities')));
      await tester.pumpAndSettle();

      final copied = await Clipboard.getData('text/plain');
      expect(
          copied?.text,
          equals([
            S.transitPTFormatModelQuantitiesHeader(1),
            S.transitPTFormatModelQuantitiesQuantity('1', 'q1', '1'),
          ].join('\n\n')));
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

// copy from https://github.com/flutter/flutter/blob/master/packages/flutter/test/widgets/clipboard_utils.dart
class MockClipboard {
  MockClipboard({
    this.hasStringsThrows = false,
  });

  final bool hasStringsThrows;

  dynamic clipboardData = <String, dynamic>{
    'text': null,
  };

  Future<Object?> handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Clipboard.getData':
        return clipboardData;
      case 'Clipboard.hasStrings':
        if (hasStringsThrows) {
          throw Exception();
        }
        final Map<String, dynamic>? clipboardDataMap = clipboardData as Map<String, dynamic>?;
        final String? text = clipboardDataMap?['text'] as String?;
        return <String, bool>{'value': text != null && text.isNotEmpty};
      case 'Clipboard.setData':
        clipboardData = methodCall.arguments;
    }
    return null;
  }
}
