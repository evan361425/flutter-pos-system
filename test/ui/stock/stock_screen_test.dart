import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/stock_screen.dart';
import 'package:provider/provider.dart';

import '../../mocks/mocks.dart';
import '../../models/repository/stock_model_test.mocks.dart';

void main() {
  testWidgets('should show loading if not ready', (tester) async {
    when(stock.isReady).thenReturn(false);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<StockModel>.value(value: stock),
    ], child: MaterialApp(home: StockScreen())));
    // wait for delay
    await tester.pump(Duration(milliseconds: 15));

    expect(find.byType(CircularLoading), findsOneWidget);
  });

  testWidgets('should show empty body if empty', (tester) async {
    when(stock.isReady).thenReturn(true);
    when(stock.isEmpty).thenReturn(true);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<StockModel>.value(value: stock),
    ], child: MaterialApp(home: StockScreen())));
    // wait for delay
    await tester.pump(Duration(milliseconds: 15));

    expect(find.byType(EmptyBody), findsOneWidget);
  });

  testWidgets('should addable', (tester) async {
    final ingredient = MockIngredientModel();
    when(ingredient.id).thenReturn('id');
    when(ingredient.name).thenReturn('name');
    when(ingredient.lastAmount).thenReturn(0);
    when(ingredient.lastAddAmount).thenReturn(0);
    when(ingredient.currentAmount).thenReturn(0);
    when(stock.isReady).thenReturn(true);
    when(stock.isEmpty).thenReturn(false);
    when(stock.updatedDate).thenReturn('hi');
    when(stock.itemList).thenReturn([ingredient]);
    when(batches.isReady).thenReturn(false);

    var navigateCount = 0;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<StockModel>.value(value: stock),
          ChangeNotifierProvider<StockBatchRepo>.value(value: batches),
        ],
        child: MaterialApp(
          routes: {
            Routes.stockIngredient: (_) => Text((navigateCount++).toString()),
          },
          home: StockScreen(),
        )));
    // wait for delay
    await tester.pump(Duration(milliseconds: 15));

    // tap to add ingredient
    await tester.tap(find.byIcon(KIcons.add).last);
    await tester.pumpAndSettle();

    expect(navigateCount, equals(1));
  });

  setUpAll(() {
    initialize();
  });
}
