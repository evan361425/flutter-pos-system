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
  group('#neededTutorial', () {
    test('should return all if non set', () {
      when(service.getString(any)).thenReturn(null);
      when(service.setString(any, any)).thenAnswer((_) => Future.value(true));

      final steps = ['s1', 's2', 's3'];

      expect(Cache.instance.neededTutorial('key', steps), equals(steps));
      verify(service.setString(any, steps.join(',')));
    });

    test('should return non record steps', () {
      when(service.getString(any)).thenReturn('s2');
      when(service.setString(any, any)).thenAnswer((_) => Future.value(true));

      final steps = ['s1', 's2', 's3'];

      expect(Cache.instance.neededTutorial('key', steps), equals(['s1', 's3']));
      verify(service.setString(any, steps.join(',')));
    });
  });

  test('#shouldCheckTutorial', () {
    when(service.getInt(any)).thenReturn(1);

    final result = Cache.instance.shouldCheckTutorial('key', 1);

    expect(result, isFalse);
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
