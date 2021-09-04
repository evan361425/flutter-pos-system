import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/customers.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/ui/model_initializer.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_repos.dart';

void main() {
  testWidgets('should return false if not ready', (tester) async {
    final qua = Quantity(name: 'q-1', id: 'q-1');
    final ing = Ingredient(name: 'i-1', id: 'i-1');
    final pQua = ProductQuantity(id: 'q-1');
    final pIng = ProductIngredient(id: 'i-1', quantities: {'q-1': pQua});
    final pro1 = Product(id: 'p-1', name: 'p-1', ingredients: {'i-1': pIng});
    final pro2 = Product(id: 'p-1', name: 'p-1', ingredients: {'i-1': pIng});
    final cat1 = Catalog(id: 'c-1', name: 'c-1', products: {'p-1': pro1});
    final cat2 = Catalog(id: 'c-2', name: 'c-2', products: {'p-2': pro2});
    when(stock.getItem(any)).thenReturn(ing);
    when(quantities.getItem(any)).thenReturn(qua);
    when(menu.items).thenReturn([cat1, cat2]);

    when(customerSettings.isReady).thenReturn(false);
    when(menu.isReady).thenReturn(false);
    when(stock.isReady).thenReturn(false);
    when(quantities.isReady).thenReturn(false);
    final notifier = _MockNotifier();

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<CustomerSettings>(
            create: (_) => customerSettings),
        ChangeNotifierProvider<Quantities>(create: (_) => quantities),
        ChangeNotifierProvider<Menu>(create: (_) => menu),
        ChangeNotifierProvider<Stock>(create: (_) => stock),
        ChangeNotifierProvider<_MockNotifier>.value(value: notifier),
      ],
      builder: (context, child) {
        context.watch<_MockNotifier>();
        return MaterialApp(home: ModelIntializer(child: Text('hi')));
      },
    ));

    expect(find.text('hi'), findsNothing);

    // stock, quantities not ready
    when(customerSettings.isReady).thenReturn(true);
    when(menu.isReady).thenReturn(true);
    notifier.go();
    await tester.pumpAndSettle();

    expect(find.text('hi'), findsNothing);

    // only quantities not ready
    when(stock.isReady).thenReturn(true);
    notifier.go();
    await tester.pumpAndSettle();

    expect(find.text('hi'), findsNothing);

    // all ready
    when(quantities.isReady).thenReturn(true);
    notifier.go();
    await tester.pumpAndSettle();

    expect(find.text('hi'), findsOneWidget);
    expect(pQua.name, equals('q-1'));
    expect(pIng.name, equals('i-1'));
  });

  setUpAll(() {
    initializeRepos();
  });
}

class _MockNotifier extends ChangeNotifier {
  void go() {
    notifyListeners();
  }
}
