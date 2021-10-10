import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import 'mocks/mock_cache.dart';
import 'mocks/mock_storage.dart';

void main() {
  testWidgets('should bind model to menu', (tester) async {
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

    await tester.pumpWidget(app);

    expect(theme.mode, ThemeMode.system);
    expect(LanguageProvider.instance.locale, LanguageProvider.defaultLocale);
    expect(CurrencyProvider.instance.currency, '新台幣');
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
