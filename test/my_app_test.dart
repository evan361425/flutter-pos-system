import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import 'mocks/mock_cache.dart';
import 'mocks/mock_storage.dart';

void main() {
  testWidgets('should bind model to menu', (tester) async {
    final menu = Menu();
    final stock = Stock();
    final quantities = Quantities();
    final theme = ThemeProvider();
    final app = MultiProvider(providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: theme),
      ChangeNotifierProvider<LanguageProvider>.value(value: LanguageProvider()),
      ChangeNotifierProvider<CurrencyProvider>.value(value: CurrencyProvider()),
    ], child: MyApp(_TestChild()));

    // for providers
    when(cache.get(any)).thenReturn(null);

    // if currency changed, it will reset cashier
    when(storage.get(any, any)).thenAnswer((_) => Future.value({}));

    // build menu
    final qua = Quantity(id: 'q-1');
    final ing = Ingredient(id: 'i-1');
    final pQua1 = ProductQuantity(id: 'pq-1', storageQuantityId: 'q-1');
    final pQua2 = ProductQuantity(id: 'pq-2', storageQuantityId: 'q-2');
    final pIng1 = ProductIngredient(
      id: 'pi-1',
      storageIngredientId: 'i-1',
      quantities: {'pq-1': pQua1, 'pq-2': pQua2},
    );
    final pIng2 = ProductIngredient(id: 'pi-2', storageIngredientId: 'i-2');
    final pro1 = Product(id: 'p-1', ingredients: {'pi-1': pIng1});
    final pro2 = Product(id: 'p-2', ingredients: {'pi-2': pIng2});
    final cat1 = Catalog(id: 'c-1', products: {'p-1': pro1});
    final cat2 = Catalog(id: 'c-2', products: {'p-2': pro2});

    // repo setup
    menu.replaceItems({'c-1': cat1, 'c-2': cat2});
    stock.replaceItems({'i-1': ing});
    quantities.replaceItems({'q-1': qua});

    await tester.pumpWidget(app);

    expect(theme.mode, ThemeMode.system);
    expect(LanguageProvider.instance.locale, LanguageProvider.defaultLocale);
    expect(CurrencyProvider.instance.currency, '新台幣');
    expect(cat1.length, 1);
    expect(cat2.length, 1);
    expect(pro1.length, 1);
    expect(pro2.length, 0);
    expect(pIng1.length, 1);
    expect(identical(pIng1.items.first, pQua1), isTrue);

    // instance will be changed after create
    await tester.pumpAndSettle();

    expect(identical(menu, Menu.instance), isFalse);
    expect(identical(stock, Stock.instance), isFalse);
    expect(identical(quantities, Quantities.instance), isFalse);
  });

  setUpAll(() {
    initializeCache();
    initializeStorage();
  });
}

class _TestChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.watch<Menu>();
    context.watch<Stock>();
    context.watch<Quantities>();
    context.watch<Replenisher>();
    context.watch<CustomerSettings>();
    context.watch<Seller>();
    return Container();
  }
}
