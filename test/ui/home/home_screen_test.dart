import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/ui/home/home_screen.dart';

import '../../mocks/mock_cache.dart';
import '../../mocks/mock_repos.dart';
import '../../mocks/mock_providers.dart';

void main() {
  testWidgets('should build correct number icons', (tester) async {
    when(cache.neededTip(any, any)).thenReturn(false);
    when(currency.numToString(any)).thenReturn('');
    when(seller.getMetricBetween(any, any))
        .thenAnswer((_) => Future.value({'totalPrice': 0}));

    var count = 0;
    HomeScreen.icons.forEach((key, value) => count += value.length);

    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    expect(find.byType(TextButton).evaluate().length, equals(count));
  });

  testWidgets('should show tip correctly', (tester) async {
    when(cache.neededTip(any, any)).thenReturn(false);
    when(cache.neededTip('home.menu', any)).thenReturn(true);
    when(cache.neededTip('home.order', any)).thenReturn(true);
    when(cache.tipRead(any, any)).thenAnswer((_) => Future.value(true));
    when(currency.numToString(any)).thenReturn('');
    when(seller.getMetricBetween(any, any))
        .thenAnswer((_) => Future.value({'totalPrice': 0}));

    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    when(cache.neededTip('home.menu', any)).thenReturn(false);
    // close tip
    await tester.tapAt(Offset(0, 0));
    await tester.pumpAndSettle();

    // show order tip
    await tester.tapAt(Offset(0, 0));
    await tester.pumpAndSettle();

    // close order tip
    when(cache.neededTip('home.order', any)).thenReturn(false);
    await tester.tapAt(Offset(0, 0));
    await tester.pumpAndSettle();

    verify(cache.tipRead('home.order', any));
  });

  setUpAll(() {
    initializeRepos();
    initializeCache();
    initializeProviders();
  });
}
