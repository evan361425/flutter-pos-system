import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/settings/currency_setting.dart';

import '../mocks/mock_cache.dart';

void main() {
  group('Currency Setting', () {
    test('set', () {
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));

      CurrencySetting().updateRemotely(CurrencyTypes.usd);

      verify(cache.set('currency', 1));
    });

    test('initialize', () {
      when(cache.get(any)).thenReturn(1);
      final currency = CurrencySetting();

      currency.initialize();

      expect(currency.isInt, false);
    });

    setUpAll(() {
      initializeCache();
    });
  });
}
