import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/services/storage.dart';
import 'package:sembast/sembast.dart';

void main() {
  late Storage storage;

  group('#sanitize', () {
    test('sould seperate ID', () {
      final result = storage.sanitize({'id.f.g': 'i'});

      expect(
          result.data,
          equals({
            'id': {
              'f': {'g': 'i'}
            }
          }));
    });

    test('alway use null(delete) first', () {
      final result = storage.sanitize({
        'some-id.a.b': 'c',
        'some-id.a': null,
        'some-id.d': {
          'e': {'a': 'b'},
          'g': 'h'
        },
        'some-id.d.e': FieldValue.delete,
      });

      expect(
          result.data,
          equals({
            'some-id': {
              'a': FieldValue.delete,
              'd': {'e': FieldValue.delete, 'g': 'h'},
            }
          }));
    });

    test('should sanitize multiple values', () {
      final result = storage.sanitize({
        'some-id.a': null,
        'some-id.b.c': {
          'a': 'b',
          'c': {'d': 'e'}
        },
        'some-id.b.c.a': 'c',
        'some-id.d.e': 'f',
        'some-id.g': {'h': null}
      });

      expect(
          result.data,
          equals({
            'some-id': {
              'a': FieldValue.delete,
              'b': {
                'c': {
                  'a': 'c',
                  'c': {'d': 'e'}
                }
              },
              'd': {'e': 'f'},
              'g': {'h': null}
            }
          }));
    });
  });

  setUp(() {
    storage = Storage();
  });
}
