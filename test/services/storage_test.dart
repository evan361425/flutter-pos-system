import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/services/storage.dart';
import 'package:sembast/sembast.dart';

void main() {
  late Storage storage;

  group('#sanitize', () {
    test('sould seperate ID', () {
      final result = <String, Map<String, Object?>?>{};

      storage.sanitize(MapEntry('id.f.g', 'i'), result);

      expect(
          result,
          equals({
            'id': {'f.g': 'i'}
          }));
    });

    test(
      'alway use null(delete) first',
      () {
        final result = <String, Map<String, Object?>?>{};
        final data = {
          'some-id.a.b': 'a',
          'some-id.a': null,
          'some-id.c': {'a': 'b', 'c': 'd'},
          'some-id.c.a': null,
        };

        data.entries.forEach((item) => storage.sanitize(item, result));

        expect(
            result,
            equals({
              'some-id': {
                'a.b': 'a',
                'a': FieldValue.delete,
                'c': {'a': 'b', 'c': 'd'},
                'c.a': FieldValue.delete
              }
            }));
      },
      skip:
          'should add this feature to avoid accedently making removment and update in same time',
    );

    test('should sanitize multiple values', () {
      final result = <String, Map<String, Object?>?>{};
      final data = {
        'some-id.a': null,
        'some-id.b.c': {
          'a': 'b',
          'c': {'d': 'e'}
        },
        'some-id.d.e': 'f',
        'some-id.g': {'h': null}
      };

      data.entries.forEach((item) => storage.sanitize(item, result));

      expect(
          result,
          equals({
            'some-id': {
              'a': FieldValue.delete,
              'b.c': {
                'a': 'b',
                'c': {'d': 'e'}
              },
              'd.e': 'f',
              'g': {'h': null}
            }
          }));
    });
  });

  setUp(() {
    storage = Storage();
  });
}
