import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/providers/currency_provider.dart';

import '../mocks/mocks.dart';
import '../test_helpers/check_notifier.dart';

void main() {
  late CurrencyProvider currency;
  group('#initialize', () {
    test('should set to default value', () {
      when(cache.get(any)).thenReturn(null);
      currency.initialize();

      expect(currency.currency, equals(CurrencyProvider.defaultCurrency));

      currency = CurrencyProvider();
      when(cache.get(any)).thenReturn(CurrencyProvider.defaultCurrency);
      currency.initialize();

      expect(currency.currency, equals(CurrencyProvider.defaultCurrency));

      currency = CurrencyProvider();
      when(cache.get(any)).thenReturn('some-wrong-currency');
      currency.initialize();

      expect(currency.currency, equals(CurrencyProvider.defaultCurrency));
    });

    test('should set correct value', () {
      when(cache.get(any)).thenReturn('USD');
      currency.initialize();

      expect(currency.currency, equals('USD'));
    });
  });

  group('#setCurrency', () {
    test('should ignore if not changed', () async {
      LOG_LEVEL = 2;
      when(cache.get(any)).thenReturn('USD');
      when(cache.set(any, 'USD')).thenAnswer((_) => Future.value(true));
      currency.initialize();

      final action = () => currency.setCurrency('USD');

      expect(await checkNotifierCalled(currency, action), isFalse);
    });

    test('should changed', () async {
      LOG_LEVEL = 2;
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, 'USD')).thenAnswer((_) => Future.value(true));
      currency.initialize();

      final action = () => currency.setCurrency('USD');

      expect(await checkNotifierCalled(currency, action), isTrue);
    });
  });

  test('#numToString', () {
    when(cache.get(any)).thenReturn(null);
    currency.initialize();

    expect(currency.numToString(12), equals('12'));
    expect(currency.numToString(12.2), equals('12'));
  });

  group('#ceil', () {
    test('should return null', () {
      expect(currency.ceil(null), isNull);
    });

    test('should return int if is float', () {
      expect(currency.ceil(12.2), equals(13));
      expect(currency.ceil(-12.2), equals(0));
    });

    test('should return first or second unit', () {
      currency.unitList = [1, 5];
      expect(currency.ceil(0), equals(1));
      expect(currency.ceil(3), equals(5));
    });

    test('should return correct value', () {
      when(cache.get(any)).thenReturn(null);
      currency.initialize();

      expect(currency.ceil(6), equals(10));
      expect(currency.ceil(11), equals(15));
      expect(currency.ceil(25), equals(30));
      expect(currency.ceil(30), equals(50));
      expect(currency.ceil(60), equals(100));
      expect(currency.ceil(100), equals(500));
    });
  });

  setUp(() {
    currency = CurrencyProvider();
  });

  setUpAll(() {
    initialize();
  });
}
