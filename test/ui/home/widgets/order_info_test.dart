import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/ui/home/widgets/order_info.dart';

import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_repos.dart';
import '../../../mocks/mock_providers.dart';

void main() {
  testWidgets('should reset', (tester) async {
    final totalPrice = 50;
    final count = 5;
    var loadCount = 0;
    when(seller.getMetricBetween()).thenAnswer((_) {
      return Future.value({
        'totalPrice': totalPrice,
        'count': count + loadCount++,
      });
    });
    when(currency.numToString(any)).thenReturn(totalPrice.toString());
    when(cache.neededTip(any, any)).thenReturn(false);

    await tester.pumpWidget(MaterialApp(home: OrderInfo()));
    await tester.pump();

    expect(find.text('5'), findsOneWidget);

    OrderInfo.resetMetadata();

    await tester.pumpAndSettle();

    expect(find.text('6'), findsOneWidget);
    expect(find.text('5'), findsNothing);
  });

  setUpAll(() {
    initializeRepos();
    initializeProviders();
    initializeCache();
  });
}
