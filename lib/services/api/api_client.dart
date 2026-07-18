import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/integration/cloud_config.dart';
import 'package:possystem/services/api/api_exception.dart';

/// Successful HTTP result from [ApiClient].
class ApiResponse {
  const ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

typedef CloudConfigLoader = CloudConfig Function();

/// Shared HTTP client for offline-first cloud sync.
///
/// Loads [CloudConfig] on every call (supports key rotation without restart).
/// Every request is bounded by [timeout] and failures become [ApiException].
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const Duration timeout = Duration(seconds: 10);

  http.Client _client = http.Client();
  CloudConfigLoader _loadConfig = CloudConfig.load;

  /// Swap the underlying [http.Client] (tests).
  @visibleForTesting
  void setHttpClient(http.Client client) {
    _client = client;
  }

  /// Override config source (tests) without touching [Cache].
  @visibleForTesting
  void setConfigLoader(CloudConfigLoader loader) {
    _loadConfig = loader;
  }

  @visibleForTesting
  void resetForTest() {
    _client = http.Client();
    _loadConfig = CloudConfig.load;
  }

  Future<ApiResponse> get(String path, {Map<String, String>? query}) {
    return _send('GET', path, query: query);
  }

  Future<ApiResponse> post(String path, {Object? body}) {
    return _send('POST', path, body: body);
  }

  Future<ApiResponse> put(String path, {Object? body}) {
    return _send('PUT', path, body: body);
  }

  Future<ApiResponse> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final config = _loadConfig();
    if (!config.isConfigured) {
      throw const ApiException(
        message: 'Cloud sync is not configured or inactive',
        statusCode: 0,
      );
    }

    final uri = _buildUri(config.storeUrl, path, query);
    final headers = <String, String>{
      'Authorization': 'Bearer ${config.apiKey}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final encodedBody = _encodeBody(body);

    Log.ger('api_request', {
      'method': method,
      'path': path,
      // Never log apiKey / Authorization (Law 5.7).
    });

    try {
      final response = await _dispatch(
        method,
        uri,
        headers: headers,
        body: encodedBody,
      ).timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          message: _truncate(
            'HTTP ${response.statusCode}: ${response.reasonPhrase ?? ''}',
          ),
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(statusCode: response.statusCode, body: response.body);
    } on ApiException {
      rethrow;
    } on TimeoutException catch (e) {
      throw ApiException(
        message: 'Request timed out after ${timeout.inSeconds}s',
        isTimeout: true,
        cause: e,
      );
    } on SocketException catch (e) {
      throw ApiException(
        message: 'Network unreachable: ${e.message}',
        cause: e,
      );
    } on http.ClientException catch (e) {
      throw ApiException(message: 'HTTP client error: ${e.message}', cause: e);
    } on HttpException catch (e) {
      throw ApiException(message: 'HTTP error: ${e.message}', cause: e);
    } catch (e) {
      throw ApiException(message: 'Unexpected API failure: $e', cause: e);
    }
  }

  Future<http.Response> _dispatch(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    String? body,
  }) {
    return switch (method) {
      'GET' => _client.get(uri, headers: headers),
      'POST' => _client.post(uri, headers: headers, body: body),
      'PUT' => _client.put(uri, headers: headers, body: body),
      _ => throw ApiException(message: 'Unsupported HTTP method: $method'),
    };
  }

  Uri _buildUri(String storeUrl, String path, Map<String, String>? query) {
    final base = storeUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final cleaned = path.replaceAll(RegExp(r'^/+'), '');
    final uri = Uri.parse('$base/$cleaned');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: {...uri.queryParameters, ...query});
  }

  String? _encodeBody(Object? body) {
    if (body == null) return null;
    if (body is String) return body;
    return jsonEncode(body);
  }

  String _truncate(String value, [int max = 200]) {
    if (value.length <= max) return value;
    return '${value.substring(0, max)}…';
  }
}
