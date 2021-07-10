import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/ui/home/home_screen.dart';

import '../../mocks/mocks.dart';
import '../../mocks/providers.dart';

void main() {
  testWidgets('should build correct number icons', (tester) async {
    when(cache.needTutorial(any)).thenReturn(false);
    when(currency.numToString(any)).thenReturn('');
    when(orders.getMetricBetween(any, any))
        .thenAnswer((_) => Future.value({'totalPrice': 0}));

    var count = 0;
    HomeScreen.icons.forEach((key, value) => count += value.length);

    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    expect(find.byType(TextButton).evaluate().length, equals(count));
  });

  setUpAll(() {
    initialize();
    initializeProviders();
  });
}
