import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/services/cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/mock_cache.dart';
import 'cache_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  group('#needTutorial', () {
    test('should return all if non set', () {
      final service = MockSharedPreferences();
      Cache.instance.service = service;
      when(service.getString(any)).thenReturn(null);
      when(service.setString(any, any)).thenAnswer((_) => Future.value(true));

      final steps = ['s1', 's2', 's3'];

      expect(Cache.instance.needTutorial('key', steps), equals(steps));
      verify(service.setString(any, steps.join(',')));
    });

    test('should return non record steps', () {
      final service = MockSharedPreferences();
      Cache.instance.service = service;
      when(service.getString(any)).thenReturn('s2');
      when(service.setString(any, any)).thenAnswer((_) => Future.value(true));

      final steps = ['s1', 's2', 's3'];

      expect(Cache.instance.needTutorial('key', steps), equals(['s1', 's3']));
      verify(service.setString(any, steps.join(',')));
    });
  });

  setUp(() {
    Cache.instance = Cache();
  });

  tearDown(() {
    Cache.instance = cache;
  });
}
