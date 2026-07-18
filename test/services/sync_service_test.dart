import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/models/integration/cloud_config.dart';
import 'package:possystem/services/api/api_client.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/sync/sync_service.dart';

import '../mocks/mock_database.dart';

void main() {
  group('SyncService', () {
    setUpAll(initializeDatabase);

    setUp(() {
      reset(database);
      Database.instance = database;
      ApiClient.instance.resetForTest();
      ApiClient.instance.setConfigLoader(
        () => const CloudConfig(
          storeUrl: 'https://api.example.com',
          apiKey: 'test-key',
          isActive: true,
        ),
      );
    });

    tearDown(() {
      ApiClient.instance.resetForTest();
    });

    test('enqueue stores payload and endpoint in sync_queue', () async {
      when(database.push('sync_queue', any)).thenAnswer((_) async => 42);

      final id = await SyncService.instance.enqueue({
        'orderId': 7,
        'price': 120,
      }, 'orders');

      expect(id, 42);

      final captured =
          verify(database.push('sync_queue', captureAny)).captured.single
              as Map<String, Object?>;

      expect(captured['endpoint'], 'orders');
      expect(captured['status'], 'pending');
      expect(captured['retry_count'], 0);
      expect(captured['payload'], contains('"orderId":7'));
      expect(captured['payload'], contains('"price":120'));
      expect(captured['created_at'], isA<int>());
      expect(captured['error_message'], isNull);
    });

    test('enqueue returns the queue row id from Database.push', () async {
      when(database.push('sync_queue', any)).thenAnswer((_) async => 99);

      final id = await SyncService.instance.enqueue({'a': 1}, 'payments');

      expect(id, 99);
      verify(database.push('sync_queue', any)).called(1);
    });

    test('processQueue POSTs payload and deletes row on 201', () async {
      http.Request? seen;
      ApiClient.instance.setHttpClient(
        MockClient((request) async {
          seen = request;
          return http.Response('{"ok":true}', 201);
        }),
      );

      var queryCalls = 0;
      when(
        database.query(
          'sync_queue',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
          limit: anyNamed('limit'),
        ),
      ).thenAnswer((_) async {
        queryCalls++;
        if (queryCalls == 1) {
          return [
            {
              'id': 1,
              'endpoint': 'orders',
              'payload': '{"orderId":7}',
              'retry_count': 0,
              'status': 'pending',
            },
          ];
        }
        return <Map<String, Object?>>[];
      });
      when(database.update('sync_queue', 1, any)).thenAnswer((_) async => 1);
      when(database.delete('sync_queue', 1)).thenAnswer((_) async => 1);

      await SyncService.instance.processQueue();

      expect(seen, isNotNull);
      expect(seen!.method, 'POST');
      expect(seen!.url.toString(), 'https://api.example.com/orders');
      expect(seen!.headers['Authorization'], 'Bearer test-key');
      expect(seen!.body, '{"orderId":7}');
      verify(database.delete('sync_queue', 1)).called(1);
    });

    test('processQueue dead-letters on HTTP 400', () async {
      ApiClient.instance.setHttpClient(
        MockClient((_) async => http.Response('bad', 400)),
      );

      var queryCalls = 0;
      when(
        database.query(
          'sync_queue',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
          limit: anyNamed('limit'),
        ),
      ).thenAnswer((_) async {
        queryCalls++;
        if (queryCalls == 1) {
          return [
            {
              'id': 2,
              'endpoint': 'orders',
              'payload': '{}',
              'retry_count': 0,
              'status': 'pending',
            },
          ];
        }
        return <Map<String, Object?>>[];
      });
      when(database.update('sync_queue', 2, any)).thenAnswer((_) async => 1);

      await SyncService.instance.processQueue();

      final updates = verify(
        database.update('sync_queue', 2, captureAny),
      ).captured.cast<Map<String, Object?>>();
      expect(updates.length, greaterThanOrEqualTo(2));
      final deadLetter = updates.last;
      expect(deadLetter['status'], 'failed');
      expect(deadLetter['retry_count'], 5);
      verifyNever(database.delete('sync_queue', 2));
    });

    test('processQueue marks failed (retryable) on HTTP 503', () async {
      ApiClient.instance.setHttpClient(
        MockClient((_) async => http.Response('busy', 503)),
      );

      var queryCalls = 0;
      when(
        database.query(
          'sync_queue',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
          limit: anyNamed('limit'),
        ),
      ).thenAnswer((_) async {
        queryCalls++;
        if (queryCalls == 1) {
          return [
            {
              'id': 3,
              'endpoint': 'orders',
              'payload': '{}',
              'retry_count': 1,
              'status': 'pending',
            },
          ];
        }
        return <Map<String, Object?>>[];
      });
      when(database.update('sync_queue', 3, any)).thenAnswer((_) async => 1);

      await SyncService.instance.processQueue();

      final updates = verify(
        database.update('sync_queue', 3, captureAny),
      ).captured.cast<Map<String, Object?>>();
      final failed = updates.last;
      expect(failed['status'], 'failed');
      expect(failed.containsKey('retry_count'), isFalse);
      verifyNever(database.delete('sync_queue', 3));
    });
  });
}
