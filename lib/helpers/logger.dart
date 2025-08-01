import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:possystem/constants/constant.dart';

const _isDebug = kDebugMode || isLocalTest;

class Log {
  static Future<void>? current;

  static void out(
    String msg,
    String code, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // print('$code: $msg, error: $error, stackTrace: $stackTrace');
    developer.log(msg, name: code, error: error, stackTrace: stackTrace);
  }

  static void ger(
    String event, [
    Map<String, Object?>? parameters,
    @visibleForTesting bool forceSend = false,
  ]) async {
    assert(!event.contains('.'), 'should not contain "."');
    final message = parameters?.entries.map((e) => '${e.key}=${e.value}').join(' ');
    Log.out(message ?? '', event);

    if (forceSend || allowSendEvents) {
      final Map<String, Object> filtered = <String, Object>{};
      parameters?.forEach((String key, Object? value) {
        if (value != null) {
          filtered[key] = value is List ? value.join(',') : value;
        }
      });

      current = FirebaseAnalytics.instance.logEvent(name: event, parameters: filtered);
    }
  }

  static void err(
    Object error,
    String code, [
    StackTrace? stackTrace,
    @visibleForTesting bool forceSend = false,
  ]) {
    assert(() {
      errorCount++;
      return !code.contains('.');
    }());
    out(error.toString(), code, error: error, stackTrace: stackTrace);

    if (forceSend || allowSendEvents) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: code,
      );
    }
  }

  // no need send event in debug mode
  static bool _allowSendEvents = !_isDebug;
  static bool get allowSendEvents => _allowSendEvents;
  static set allowSendEvents(bool value) => _allowSendEvents = _isDebug ? false : value;

  @visibleForTesting
  static int errorCount = 0;
}
