/// Typed HTTP / network failure for POS cloud calls.
///
/// Services branch on [isClientError] (dead-letter) vs
/// [isNetworkError] / [isServerError] (outbox retry).
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode = 0,
    this.isTimeout = false,
    this.cause,
  });

  final String message;
  final int statusCode;
  final bool isTimeout;
  final Object? cause;

  /// No HTTP response (timeout, socket, not configured, etc.).
  bool get isNetworkError => statusCode == 0;

  /// 4xx — malformed / auth / not found: do not retry forever.
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// 5xx — transient backend fault: safe to retry.
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
