import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/services/storage.dart';
import 'package:sembast/sembast_memory.dart';

import '../test_helpers/file_mocker.dart';

void main() {
  late Storage storage;

  group('Storage', () {
    late DatabaseFactory factory;

    group('#sanitize', () {
      test('should separate ID', () {
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

    group('StorageSanitizedData', () {
      test('updateOverlap', () {
        final a = {
          'a': 'a',
          'b': {'b1': 'b1'}
        };
        final d = StorageSanitizedData();
        d.updateOverlap(a, {
          'a': 'a2',
          'c': 'c',
          'b': {'b1': 'b2'}
        });
        expect(
            a,
            equals({
              'a': 'a2',
              'c': 'c',
              'b': {'b1': 'b2'}
            }));
      });
    });

    test('#add', () async {
      await storage.add(Stores.menu, 'hi', {'a': 'b'});
      final result = await storage.get(Stores.menu, 'hi');
      expect(result, equals({'a': 'b'}));
    });

    test('#get', () async {
      final result = await storage.get(Stores.menu, 'hi');
      expect(result, isEmpty);
    });

    test('#get - all', () async {
      await storage.add(Stores.menu, 'hi', {'a': 'b'});
      await storage.add(Stores.menu, 'there', {'b': 'c'});
      final result = await storage.get(Stores.menu);
      expect(result, {
        'hi': {'a': 'b'},
        'there': {'b': 'c'}
      });
    });

    test('#set', () async {
      Future<void> verifyResult(Map expected) async {
        final result = await storage.get(Stores.menu, 'a');
        expect(result, expected);
      }

      await storage.add(Stores.menu, 'a', {'old': 'value'});
      await storage.set(Stores.menu, {
        'a': {'b': 'c'},
      });
      verifyResult({'old': 'value', 'b': 'c'});

      // delete field
      await storage.set(Stores.menu, {'a.b': null});
      verifyResult({'old': 'value'});

      // delete all
      await storage.set(Stores.menu, {'a': null});
      verifyResult({});

      // must be map
      await storage.add(Stores.menu, 'a', {'b': 'c'});
      await storage.set(Stores.menu, {'a.c': 2, 'a': 'b'});
      verifyResult({'c': 2, 'b': 'c'});
    });

    test('#setAll', () async {
      await storage.setAll(Stores.menu, {
        'a': {'b': 'c', 'd': 'e'},
        'b': {'a': 'a'}
      });
      await storage.setAll(Stores.menu, {
        'a': {'d': 'f'}
      });
      final result = await storage.get(Stores.menu);
      expect(result, {
        'a': {'b': 'c', 'd': 'f'},
        'b': {'a': 'a'}
      });
    });

    test('#initialize', () async {
      await storage.initialize(opener: factory.openDatabase);
    });

    test('#reset', () async {
      await storage.reset(Stores.menu);
      await storage.reset(null, factory.deleteDatabase);
    });

    setUp(() async {
      factory = newDatabaseFactoryMemory();
      storage = Storage();
      storage.db = await factory.openDatabase('');
    });

    setUpAll(() {
      initializeFileSystem();
    });
  });
}
