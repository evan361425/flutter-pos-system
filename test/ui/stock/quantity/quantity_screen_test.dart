import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/quantity_repo.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/quantity/quantity_screen.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mocks.dart';
import '../../../mocks/providers.dart';
import '../../../models/repository/quantity_repo_test.mocks.dart';

void main() {
  testWidgets('should show loading when not ready', (tester) async {
    when(quantities.isReady).thenReturn(false);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<QuantityRepo>.value(value: quantities),
    ], child: MaterialApp(home: QuantityScreen())));

    expect(find.byType(CircularLoading), findsOneWidget);
  });

  testWidgets('should show empty body when empty', (tester) async {
    when(quantities.isReady).thenReturn(true);
    when(quantities.isEmpty).thenReturn(true);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<QuantityRepo>.value(value: quantities),
    ], child: MaterialApp(home: QuantityScreen())));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should addable', (tester) async {
    final quantity = MockQuantityModel();
    when(quantity.id).thenReturn('id');
    when(quantity.name).thenReturn('name');
    when(quantity.defaultProportion).thenReturn(0);
    when(quantities.isReady).thenReturn(true);
    when(quantities.isEmpty).thenReturn(false);
    when(quantities.itemList).thenReturn([quantity]);

    var navigateCount = 0;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<QuantityRepo>.value(value: quantities),
        ],
        child: MaterialApp(
          routes: {
            Routes.stockQuantityModal: (_) =>
                Text((navigateCount++).toString()),
          },
          home: QuantityScreen(),
        )));

    // tap to add ingredient
    await tester.tap(find.byIcon(KIcons.add).last);
    await tester.pumpAndSettle();

    expect(navigateCount, equals(1));
  });

  setUpAll(() {
    initialize();
    initializeProviders();
  });
}
