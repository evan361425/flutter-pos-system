import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/services/storage.dart';
import 'package:sembast/sembast.dart';

void main() {
  late Storage storage;

  group('Storage', () {
    group('#sanitize', () {
      test('sould seperate ID', () {
        final result = storage.sanitize({'id.f.g': 'i'});

        expect(
            result.data,
            equals({
              'id': {'f.g': 'i'}
            }));
      });

      test('alway get field delete in null', () {
        final result = storage.sanitize({
          'some-id.a.b': 'c',
          'some-id.a': null,
        });

        expect(
            result.data,
            equals({
              'some-id': {
                'a.b': 'c',
                'a': FieldValue.delete,
              }
            }));
      });

      test('should sanitize multiple values', () {
        final result = storage.sanitize({
          'some-id.a': null,
          'some-id.b.c.a': 'c',
          'some-id.g': {'h': null}
        });

        expect(
            result.data,
            equals({
              'some-id': {
                'a': FieldValue.delete,
                'b.c.a': 'c',
                'g': {'h': null}
              }
            }));
      });
    });

    setUp(() {
      storage = Storage();
    });
  });
}
