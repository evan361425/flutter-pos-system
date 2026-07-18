import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/services/api/api_client.dart';
import 'package:possystem/services/api/api_exception.dart';
import 'package:possystem/services/database.dart';

/// Service for managing offline-first synchronization queue.
///
/// This service implements an outbox pattern where transactions are stored
/// locally in a SQLite queue and asynchronously synchronized to the cloud
/// backend when connectivity is restored.
class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  static const int _maxRetries = 5;
  static const int _batchSize = 50;
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _processingDelay = Duration(milliseconds: 100);

  Timer? _periodicTimer;
  bool _isProcessing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _wasOnline = false;

  /// Initialize the sync service and start background processing.
  Future<void> initialize() async {
    _startPeriodicSync();
    _listenToConnectivity();
    await _processPendingQueue();
  }

  /// Enqueue a payload for synchronization.
  ///
  /// [payload] - The JSON-serializable payload to sync.
  /// [endpoint] - The API endpoint identifier (e.g., 'orders', 'payments').
  /// Returns the queue entry ID.
  Future<int> enqueue(Object payload, String endpoint) async {
    final jsonString = jsonEncode(payload);
    final createdAt = DateTime.now().millisecondsSinceEpoch;

    final id = await Database.instance.push('sync_queue', {
      'payload': jsonString,
      'endpoint': endpoint,
      'status': 'pending',
      'retry_count': 0,
      'error_message': null,
      'created_at': createdAt,
    });

    Log.ger('sync_enqueue', {'id': id, 'endpoint': endpoint});
    return id;
  }

  /// Process all pending and failed (under max retries) queue items.
  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      await _processPendingQueue();
    } finally {
      _isProcessing = false;
    }
  }

  /// Process pending queue items in batches.
  Future<void> _processPendingQueue() async {
    while (true) {
      final items = await Database.instance.query(
        'sync_queue',
        where: "status IN ('pending', 'failed') AND retry_count < ?",
        whereArgs: [_maxRetries],
        orderBy: 'created_at ASC',
        limit: _batchSize,
      );

      if (items.isEmpty) break;

      for (final item in items) {
        await _processQueueItem(item);
        await Future.delayed(_processingDelay);
      }
    }
  }

  /// Process a single queue item.
  Future<void> _processQueueItem(Map<String, Object?> item) async {
    final id = item['id'] as int;
    final endpoint = item['endpoint'] as String;
    final payload = item['payload'] as String;
    final retryCount = item['retry_count'] as int;

    Log.ger('sync_processing', {
      'id': id,
      'endpoint': endpoint,
      'attempt': retryCount + 1,
    });

    await Database.instance.update('sync_queue', id, {
      'status': 'processing',
      'retry_count': retryCount + 1,
    });

    try {
      await _sendToCloud(endpoint, payload);
      await _markSynced(id);
      Log.ger('sync_success', {'id': id, 'endpoint': endpoint});
    } on ApiException catch (e, stack) {
      Log.err(e, 'sync_error', stack);
      if (e.isClientError) {
        // 4xx: malformed / rejected — dead-letter (no infinite retry).
        await _markDeadLetter(id, e.toString());
      } else {
        // Network / timeout / 5xx — leave failed for outbox retry.
        await _markFailed(id, e.toString());
      }
    } catch (e, stack) {
      Log.err(e, 'sync_error', stack);
      await _markFailed(id, e.toString());
    }
  }

  /// POST [payload] JSON to `storeUrl / [endpoint]` via [ApiClient].
  Future<void> _sendToCloud(String endpoint, String payload) async {
    final response = await ApiClient.instance.post(endpoint, body: payload);
    if (response.statusCode != 200 && response.statusCode != 201) {
      // Other 2xx are unexpected for our outbox contract.
      throw ApiException(
        message: 'Unexpected success status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Mark queue item as successfully synced (delete from queue).
  Future<void> _markSynced(int id) async {
    await Database.instance.delete('sync_queue', id);
  }

  /// Mark queue item as failed with error message (retryable).
  Future<void> _markFailed(int id, String errorMessage) async {
    await Database.instance.update('sync_queue', id, {
      'status': 'failed',
      'error_message': errorMessage,
    });
  }

  /// Permanent failure: status failed + retry_count at max (dead letter).
  Future<void> _markDeadLetter(int id, String errorMessage) async {
    await Database.instance.update('sync_queue', id, {
      'status': 'failed',
      'retry_count': _maxRetries,
      'error_message': errorMessage,
    });
  }

  /// Start periodic timer to process queue.
  void _startPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_syncInterval, (_) {
      if (!_isProcessing) {
        processQueue();
      }
    });
  }

  /// Listen to connectivity changes and trigger sync when online.
  void _listenToConnectivity() {
    _wasOnline = false;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isOnline =
            results.isNotEmpty &&
            results.any((r) => r != ConnectivityResult.none);

        if (isOnline && !_wasOnline) {
          Log.ger('connectivity_online', {
            'results': results.map((e) => e.name).toList(),
          });
          processQueue();
        }

        _wasOnline = isOnline;
      },
      onError: (error, stack) {
        Log.err(error, 'connectivity_stream_error', stack);
      },
    );

    _checkInitialConnectivity();
  }

  /// Check initial connectivity state on startup.
  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final isOnline =
          results.isNotEmpty &&
          results.any((r) => r != ConnectivityResult.none);
      _wasOnline = isOnline;

      if (isOnline) {
        Log.ger('initial_connectivity_online', {
          'results': results.map((e) => e.name).toList(),
        });
        Future.delayed(const Duration(seconds: 2), processQueue);
      }
    } catch (e, stack) {
      Log.err(e, 'initial_connectivity_check_failed', stack);
      _wasOnline = true;
    }
  }

  /// Get count of pending queue items.
  Future<int> getPendingCount() async {
    return await Database.instance.count(
          'sync_queue',
          where: "status IN ('pending', 'failed') AND retry_count < ?",
          whereArgs: [_maxRetries],
        ) ??
        0;
  }

  /// Get count of failed items that exceeded max retries.
  Future<int> getDeadLetterCount() async {
    return await Database.instance.count(
          'sync_queue',
          where: 'status = ? AND retry_count >= ?',
          whereArgs: ['failed', _maxRetries],
        ) ??
        0;
  }

  /// Recent outbox failures for operator diagnostics (settings UI).
  Future<List<SyncQueueFailure>> getFailedItems({int limit = 30}) async {
    final rows = await Database.instance.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: const ['failed'],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(SyncQueueFailure.fromMap).toList();
  }

  /// Clean up successfully synced items older than [maxAge].
  Future<int> cleanupSyncedItems({
    Duration maxAge = const Duration(days: 7),
  }) async {
    final cutoff = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;
    final db = Database.instance.db;

    final result = await db.delete(
      'sync_queue',
      where: 'status = ? AND created_at < ?',
      whereArgs: ['synced', cutoff],
    );

    if (result > 0) {
      Log.ger('sync_cleanup', {'deleted': result});
    }
    return result;
  }

  /// Dispose resources.
  void dispose() {
    _periodicTimer?.cancel();
    _connectivitySubscription?.cancel();
  }
}

/// Snapshot of a failed [sync_queue] row for settings diagnostics.
class SyncQueueFailure {
  const SyncQueueFailure({
    required this.id,
    required this.endpoint,
    required this.errorMessage,
    required this.retryCount,
    required this.createdAt,
  });

  final int id;
  final String endpoint;
  final String errorMessage;
  final int retryCount;
  final DateTime createdAt;

  factory SyncQueueFailure.fromMap(Map<String, Object?> map) {
    final ms = map['created_at'] as int? ?? 0;
    return SyncQueueFailure(
      id: map['id'] as int? ?? 0,
      endpoint: map['endpoint'] as String? ?? '',
      errorMessage: map['error_message'] as String? ?? '',
      retryCount: map['retry_count'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(ms),
    );
  }
}
