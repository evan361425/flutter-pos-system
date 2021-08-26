import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/ui/home/home_screen.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_repos.dart';
import '../../mocks/mock_providers.dart';

void main() {
  testWidgets('should build correct number icons', (tester) async {
    when(cache.getRaw(any)).thenReturn(1);
    when(currency.numToString(any)).thenReturn('');
    when(seller.getMetricBetween(any, any))
        .thenAnswer((_) => Future.value({'totalPrice': 0}));

    var count = 0;
    HomeScreen.icons.forEach((key, value) => count += value.length);

    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    expect(find.byType(TextButton).evaluate().length, equals(count));
  });

  testWidgets('should show tip correctly', (tester) async {
    when(cache.getRaw(any)).thenReturn(1);
    when(cache.getRaw('_tip.home.menu')).thenReturn(0);
    when(cache.getRaw('_tip.home.order')).thenReturn(0);
    when(cache.setRaw(any, any)).thenAnswer((_) => Future.value(true));
    when(currency.numToString(any)).thenReturn('');
    when(seller.getMetricBetween(any, any))
        .thenAnswer((_) => Future.value({'totalPrice': 0}));

    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    // show menu tip animation
    await tester.pumpAndSettle();

    when(cache.getRaw('_tip.home.menu')).thenReturn(1);

    // close tip
    await tester.tapAt(Offset(0, 0));
    // close and start animation
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    verify(cache.setRaw('_tip.home.menu', isNonZero));

    // close order tip
    when(cache.getRaw('_tip.home.order')).thenReturn(1);

    // close tip
    await tester.tapAt(Offset(0, 0));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    verify(cache.setRaw('_tip.home.order', isNonZero));
  });

  setUpAll(() {
    initializeRepos();
    initializeCache();
    initializeProviders();
  });
}
