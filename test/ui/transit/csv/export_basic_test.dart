import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/xfile.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/field_formatter.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';
import 'package:possystem/ui/transit/transit_station.dart';

import '../../../test_helpers/file_mocker.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Transit - CSV - Export Basic', () {
    Widget buildApp() {
      return MaterialApp.router(
        routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const TransitStation(
              catalog: TransitCatalog.exportModel,
              method: TransitMethod.csv,
            ),
          ),
        ]),
      );
    }

    testWidgets('successfully', (tester) async {
      final picker = mockFilePicker();
      mockFileSave(picker);

      Quantities.instance.replaceItems({'q1': Quantity(id: 'q1', name: 'q1')});
      Stock.instance.replaceItems({'i1': Ingredient(id: 'i1', name: 'i1', totalAmount: 100)});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('transit.model_picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.model_picker._all')), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.model_export')));
      await tester.pumpAndSettle();

      expect(find.text(S.transitExportBasicSuccessCsv), findsOneWidget);

      final header1 = findFieldFormatter(FormattableModel.stock).getHeader().map((e) => e.toString()).join(',');
      verify(picker.saveFile(
        dialogTitle: anyNamed('dialogTitle'),
        fileName: '${FormattableModel.stock.l10nName}.csv',
        bytes: utf8.encode('$header1\ni1,0.0,100,,1.0'),
      ));

      final path = '${XFile.fs.systemTempDirectory.path}/${FormattableModel.quantities.l10nName}.csv';
      final header2 = findFieldFormatter(FormattableModel.quantities).getHeader().map((e) => e.toString()).join(',');
      expect(XFile(path).file.readAsBytesSync().toList(), utf8.encode('$header2\nq1,1'));
    });

    testWidgets('abort saving', (tester) async {
      final picker = mockFilePicker();
      mockFileSave(picker, canceled: true);

      Quantities.instance.replaceItems({'q1': Quantity(id: 'q1', name: 'q1')});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // empty data export
      await tester.tap(find.byKey(const Key('transit.model_export')));
      await tester.pumpAndSettle();

      expect(find.text(S.transitExportBasicSuccessCsv), findsNothing);

      await tester.tap(find.text(FormattableModel.quantities.l10nName));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('transit.model_export')));
      await tester.pumpAndSettle();

      expect(find.text(S.transitExportBasicSuccessCsv), findsNothing);
    });

    setUpAll(() {
      initializeTranslator();
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
