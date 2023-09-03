import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/ui/transit/transit_page.dart';

import '../../mocks/mock_auth.dart';
import '../../mocks/mock_cache.dart';
import '../../test_helpers/translator.dart';

void main() {
  group('Exporter Screen', () {
    testWidgets('nav', (tester) async {
      const keys = ['exporter.google_sheet', 'exporter.plain_text'];

      when(cache.get(any)).thenReturn(null);

      await tester.pumpWidget(MaterialApp(home: TransitPage()));

      for (var key in keys) {
        await tester.tap(find.byKey(Key(key)));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.arrow_back_ios_sharp));
        await tester.pumpAndSettle();
      }
    });

    setUp(() {
      Menu();
      Stock();
      Quantities();
      Replenisher();
      OrderAttributes();
      Seller();
      CurrencySetting().isInt = true;
      when(auth.authStateChanges()).thenAnswer((_) => Stream.value(null));
    });

    setUpAll(() {
      initializeTranslator();
      initializeCache();
      initializeAuth();
    });
  });
}
