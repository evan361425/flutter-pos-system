import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:possystem/models/integration/cloud_config.dart';
import 'package:possystem/services/api/api_client.dart';
import 'package:possystem/services/api/api_exception.dart';

void main() {
  group('ApiClient', () {
    setUp(() {
      ApiClient.instance.resetForTest();
      ApiClient.instance.setConfigLoader(
        () => const CloudConfig(
          storeUrl: 'https://shop.example.com/',
          apiKey: 'secret-key',
          isActive: true,
        ),
      );
    });

    tearDown(() {
      ApiClient.instance.resetForTest();
    });

    test(
      'GET builds URL without trailing slash and sends Bearer header',
      () async {
        http.Request? seen;
        ApiClient.instance.setHttpClient(
          MockClient((request) async {
            seen = request;
            return http.Response('[]', 200);
          }),
        );

        final response = await ApiClient.instance.get(
          'ecommerce/orders/pending',
        );

        expect(response.isSuccess, isTrue);
        expect(
          seen!.url.toString(),
          'https://shop.example.com/ecommerce/orders/pending',
        );
        expect(seen!.headers['Authorization'], 'Bearer secret-key');
        expect(seen!.headers['Accept'], 'application/json');
      },
    );

    test('POST sends JSON body string as-is', () async {
      http.Request? seen;
      ApiClient.instance.setHttpClient(
        MockClient((request) async {
          seen = request;
          return http.Response('{}', 201);
        }),
      );

      await ApiClient.instance.post('orders', body: '{"a":1}');

      expect(seen!.method, 'POST');
      expect(seen!.body, '{"a":1}');
    });

    test('throws ApiException with isClientError on 422', () async {
      ApiClient.instance.setHttpClient(
        MockClient((_) async => http.Response('nope', 422)),
      );

      try {
        await ApiClient.instance.post('orders', body: '{}');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.statusCode, 422);
        expect(e.isClientError, isTrue);
        expect(e.isServerError, isFalse);
        expect(e.isNetworkError, isFalse);
      }
    });

    test('throws ApiException with isServerError on 500', () async {
      ApiClient.instance.setHttpClient(
        MockClient((_) async => http.Response('err', 500)),
      );

      try {
        await ApiClient.instance.get('orders');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.isServerError, isTrue);
        expect(e.isClientError, isFalse);
      }
    });

    test('throws ApiException with isTimeout on TimeoutException', () async {
      ApiClient.instance.setHttpClient(
        MockClient((_) async {
          throw TimeoutException('slow');
        }),
      );

      try {
        await ApiClient.instance.get('orders');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.isTimeout, isTrue);
        expect(e.isNetworkError, isTrue);
      }
    });

    test('throws when cloud is not configured', () async {
      ApiClient.instance.setConfigLoader(() => const CloudConfig());

      expect(
        () => ApiClient.instance.get('orders'),
        throwsA(
          isA<ApiException>().having((e) => e.isNetworkError, 'network', true),
        ),
      );
    });
  });
}
