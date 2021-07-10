import 'package:mockito/annotations.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/providers/language_provider.dart';
import 'package:possystem/providers/theme_provider.dart';

import 'providers.mocks.dart';

final theme = MockThemeProvider();
final language = MockLanguageProvider();
final currency = MockCurrencyProvider();

@GenerateMocks([
  ThemeProvider,
  LanguageProvider,
  CurrencyProvider,
])
void _initialize() {
  CurrencyProvider.instance = currency;
  _finished = true;
}

var _finished = false;
void initializeProviders() {
  if (!_finished) {
    _initialize();
  }
}
