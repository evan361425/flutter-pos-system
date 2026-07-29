import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/settings/currency_setting.dart';

import '../mocks/mock_cache.dart';

void main() {
  group('Currency Setting', () {
    test('set', () {
      when(cache.set(any, any)).thenAnswer((_) => Future.value(true));

      CurrencySetting.instance.updateRemotely(.usd);

      verify(cache.set('currency', 2));
    });

    test('initialize', () {
      when(cache.get(any)).thenReturn(0);

      CurrencySetting.instance.initialize();

      expect(CurrencySetting.instance.isInt, false);
      final formatted = CurrencySetting.instance.formatter.format(1234.5);
      expect(formatted, contains('1.234,50'));
      expect(formatted, contains('€'));
    });

    setUpAll(() {
      initializeCache();
    });
  });
}
