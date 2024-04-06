import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/services/cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cache_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences service;

  group('Cache', () {
    test('#initialize', () async {
      SharedPreferences.setMockInitialValues({});

      await Cache.instance.initialize();
      // only initialize once
      await Cache.instance.initialize();

      expect(Cache.instance.get<int>('version'), equals(1));

      await Cache.instance.reset();

      expect(Cache.instance.get<int>('version'), isNull);
    });

    test('#get', () {
      when(service.getBool('a')).thenReturn(true);
      expect(Cache.instance.get<bool>('a'), isTrue);

      when(service.getString('b')).thenReturn('true');
      expect(Cache.instance.get<String>('b'), equals('true'));

      when(service.getInt('c')).thenReturn(0);
      expect(Cache.instance.get<int>('c'), isZero);

      when(service.getDouble('d')).thenReturn(1.0);
      expect(Cache.instance.get<double>('d'), equals(1.0));
    });

    test('#set', () {
      when(service.setBool('a', true)).thenAnswer((_) => Future.value(true));
      Cache.instance.set<bool>('a', true);

      when(service.setString('b', 'true')).thenAnswer((_) => Future.value(true));
      Cache.instance.set<String>('b', 'true');

      when(service.setInt('c', 0)).thenAnswer((_) => Future.value(true));
      Cache.instance.set<int>('c', 0);

      when(service.setDouble('d', 1.0)).thenAnswer((_) => Future.value(true));
      Cache.instance.set<double>('d', 1.0);
    });

    test('throw to get/set unsupport type', () {
      expect(() => Cache.instance.get<List>('a'), throwsArgumentError);
      expect(() => Cache.instance.set<List>('a', []), throwsArgumentError);
    });

    setUp(() {
      service = MockSharedPreferences();
      Cache.instance = Cache();
      Cache.instance.service = service;
    });
  });
}
