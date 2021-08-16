import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_cache.dart';
import '../mocks/mock_database.dart';
import '../mocks/mock_repos.dart';
import '../mocks/mock_providers.dart';
import '../mocks/mock_storage.dart';

void main() {
  testWidgets('should nout initialized before prepared', (tester) async {
    final app = MultiProvider(providers: [
      ChangeNotifierProvider<ThemeProvider>.value(value: theme),
      ChangeNotifierProvider<LanguageProvider>.value(
          value: LanguageProvider.instance),
      ChangeNotifierProvider<CurrencyProvider>.value(value: currency),
      ChangeNotifierProvider<Menu>.value(value: menu),
      ChangeNotifierProvider<Stock>.value(value: stock),
      ChangeNotifierProvider<Quantities>.value(value: quantities),
    ], child: MyApp(isDebug: false));

    when(menu.isReady).thenReturn(false);
    when(database.initialize())
        .thenAnswer((_) => Future.delayed(Duration(milliseconds: 30)));
    when(storage.initialize()).thenAnswer((_) => Future.value());
    when(cache.initialize()).thenAnswer((_) => Future.value());
    when(cache.get(any)).thenReturn(null);
    when(cache.neededTip(any, any)).thenReturn(false);

    when(currency.numToString(any)).thenReturn('');
    when(theme.isReady).thenReturn(false);

    // home page order info
    when(seller.getMetricBetween(any, any))
        .thenAnswer((_) => Future.value({'totalPrice': 0}));

    await tester.pumpWidget(app);
    await tester.pump();

    verifyNever(theme.initialize());

    await tester.pumpAndSettle();

    verify(theme.initialize()).called(1);
  });

  setUpAll(() {
    initializeRepos();
    initializeCache();
    initializeDatabase();
    initializeProviders();
    initializeStorage();
  });

  setUp(() {
    LanguageProvider.instance = LanguageProvider();
  });

  tearDown(() {
    LanguageProvider.instance = language;
  });
}
