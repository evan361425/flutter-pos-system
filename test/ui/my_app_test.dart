import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/repository/order_repo.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import '../mocks/mock_database.dart';
import '../mocks/mocks.dart';
import '../mocks/providers.dart';

void main() {
  testWidgets('should nout initialized before prepared', (tester) async {
    final app = MultiProvider(providers: [
      ChangeNotifierProvider<ThemeProvider>(create: (_) => theme),
      ChangeNotifierProvider<LanguageProvider>(create: (_) => language),
      ChangeNotifierProvider<CurrencyProvider>(create: (_) => currency),
    ], child: MyApp(isDebug: false));
    when(database.initialize())
        .thenAnswer((_) => Future.delayed(Duration(milliseconds: 30)));
    when(orders.getMetricBetween(any, any))
        .thenAnswer((_) => Future.value({'totalPrice': 0}));
    when(storage.initialize()).thenAnswer((_) => Future.value());
    when(cache.initialize()).thenAnswer((_) => Future.value());
    when(cache.needTutorial(any)).thenReturn(false);

    when(currency.numToString(any)).thenReturn('');
    when(language.isReady).thenReturn(false);
    when(theme.isReady).thenReturn(false);
    when(language.localeListResolutionCallback(any, any))
        .thenReturn(Locale('zh', 'TW'));

    await tester.pumpWidget(app);
    await tester.pump();

    verifyNever(theme.initialize());

    await tester.pumpAndSettle();

    verify(theme.initialize()).called(1);
  });

  setUpAll(() {
    initialize();
    initializeDatabase();
    initializeProviders();
  });
}
