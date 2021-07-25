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
    test('should return false if set', () {
      final service = MockSharedPreferences();
      Cache.instance.service = service;
      when(service.getBool(any)).thenReturn(false);

      // get false should return false
      expect(Cache.instance.needTutorial('some-key'), equals(false));

      when(service.getBool(any)).thenReturn(true);

      // get true should return false
      expect(Cache.instance.needTutorial('some-key'), equals(false));
    });

    test('should return true if not set', () {
      final service = MockSharedPreferences();
      Cache.instance.service = service;
      when(service.getBool(any)).thenReturn(null);
      when(service.setBool(any, any)).thenAnswer((_) => Future.value(false));

      // Action
      final result = Cache.instance.needTutorial('some-key');

      // Assertion
      expect(result, equals(true));
      verify(service.setBool(any, any)).called(1);
    });
  });

  setUp(() {
    Cache.instance = Cache();
  });

  tearDown(() {
    Cache.instance = cache;
  });
}
