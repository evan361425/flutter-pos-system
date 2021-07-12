import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock_batch_repo.dart';
import 'package:possystem/models/stock/ingredient_model.dart';
import 'package:possystem/models/stock/stock_batch_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/widgets/stock_batch_actions.dart';
import 'package:provider/provider.dart';

import '../../../mocks/mocks.dart';

void main() {
  testWidgets('should loading if not ready', (tester) async {
    when(batches.isReady).thenReturn(false);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<StockBatchRepo>.value(value: batches),
    ], child: MaterialApp(home: StockBatchActions())));

    expect(find.byType(CircularLoading), findsOneWidget);
  });

  testWidgets('should do nothing if add batch in default', (tester) async {
    when(batches.isReady).thenReturn(true);
    when(batches.items).thenReturn([]);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<StockBatchRepo>.value(value: batches),
    ], child: MaterialApp(home: Material(child: StockBatchActions()))));

    await tester.tap(find.byIcon(Icons.add_circle_outline_sharp));

    expect(find.byType(ConfirmDialog), findsNothing);
  });

  testWidgets('should navigate if edit batch in default', (tester) async {
    when(batches.isReady).thenReturn(true);
    when(batches.items).thenReturn([]);

    var navigateCount = 0;

    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<StockBatchRepo>.value(value: batches),
        ],
        child: MaterialApp(
          routes: {
            Routes.stockBatchModal: (context) {
              expect(ModalRoute.of(context)!.settings.arguments, isNull);
              return Text((navigateCount++).toString());
            },
          },
          home: Material(child: StockBatchActions()),
        )));

    await tester.tap(find.byIcon(KIcons.edit));
    await tester.pumpAndSettle();

    expect(navigateCount, equals(1));
  });

  testWidgets('should show confirm when select', (tester) async {
    final batch = StockBatchModel(name: 'name', id: 'id', data: {'ing-1': 20});
    final ingredient = IngredientModel(name: 'ing-name', id: 'ing-1');
    when(batches.isReady).thenReturn(true);
    when(batches.items).thenReturn([batch]);
    when(batches.getItem('id')).thenReturn(batch);
    when(stock.getItem('ing-1')).thenReturn(ingredient);

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider<StockBatchRepo>.value(value: batches),
    ], child: MaterialApp(home: Material(child: StockBatchActions()))));

    // show drop down
    await tester.tap(find.byKey(StockBatchActions.selector));
    await tester.pumpAndSettle();

    // select batch
    await tester.tap(find.text('name').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_circle_outline_sharp));
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmDialog), findsOneWidget);
    expect(find.text('- ing-name'), findsOneWidget);
  });

  setUpAll(() {
    initialize();
  });
}
