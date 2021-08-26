import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/services/cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_cache.dart';
import 'cache_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences service;
  test('#get', () {
    when(service.getBool('Caches.currency_code')).thenReturn(true);
    expect(Cache.instance.get<bool>(Caches.currency_code), isTrue);

    when(service.getString('Caches.currency_code')).thenReturn('true');
    expect(Cache.instance.get<String>(Caches.currency_code), equals('true'));

    when(service.getInt('Caches.currency_code')).thenReturn(0);
    expect(Cache.instance.get<int>(Caches.currency_code), isZero);

    when(service.getDouble('Caches.currency_code')).thenReturn(1.0);
    expect(Cache.instance.get<double>(Caches.currency_code), equals(1.0));
  });

  test('#set', () {
    when(service.setBool('Caches.currency_code', true))
        .thenAnswer((_) => Future.value(true));
    Cache.instance.set<bool>(Caches.currency_code, true);

    when(service.setString('Caches.currency_code', 'true'))
        .thenAnswer((_) => Future.value(true));
    Cache.instance.set<String>(Caches.currency_code, 'true');

    when(service.setInt('Caches.currency_code', 0))
        .thenAnswer((_) => Future.value(true));
    Cache.instance.set<int>(Caches.currency_code, 0);

    when(service.setDouble('Caches.currency_code', 1.0))
        .thenAnswer((_) => Future.value(true));
    Cache.instance.set<double>(Caches.currency_code, 1.0);
  });

  test('throw to get/set unsupport type', () {
    expect(
      () => Cache.instance.get<List>(Caches.currency_code),
      throwsArgumentError,
    );
    expect(
      () => Cache.instance.set<List>(Caches.currency_code, []),
      throwsArgumentError,
    );
  });

  setUp(() {
    service = MockSharedPreferences();
    Cache.instance = Cache();
    Cache.instance.service = service;
  });

  tearDown(() {
    Cache.instance = cache;
  });
}
