import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

const _level = String.fromEnvironment('LOG_LEVEL', defaultValue: 'debug');
// var for testing
var logLevel = _level == 'error'
    ? 1
    : _level == 'warn'
        ? 2
        : _level == 'info'
            ? 3
            : 4;

Future<void> _log(
    String message, String code, Map<String, Object>? detail, int level) async {
  developer.log(message, name: code);
  // no need send debug event
  if (logLevel == 4) return;

  detail ??= {};
  detail['message'] = message;

  await FirebaseAnalytics.instance.logEvent(
    name: code.split('.').join('_'),
    parameters: detail,
  );
}

Future<void> waitLog(String message, String code,
    [Map<String, Object>? detail]) async {
  await _log(message, code, detail, 4);
}

/// DEBUG mode logging
///
/// LEVEL: 4
void debug(String message, String code, [Map<String, Object>? detail]) async {
  if (logLevel > 3) {
    await _log(message, code, detail, 4);
  }
}

/// INFO mode logging
///
/// LEVEL: 3
void info(String message, String code, [Map<String, Object>? detail]) async {
  if (logLevel > 2) {
    await _log(message, code, detail, 3);
  }
}

/// WARN mode logging
///
/// LEVEL: 2
void warn(String message, String code, [Map<String, Object>? detail]) async {
  if (logLevel > 1) {
    await _log(message, code, detail, 2);
  }
}

/// ERROR mode logging
///
/// LEVEL: 1
///
/// It will send to crashlytics not analytic
Future<void> error(
  String message,
  String code, [
  StackTrace? stack,
  bool? printDetails,
]) async {
  developer.log(message, name: code);

  if (logLevel == 4) return;

  await FirebaseCrashlytics.instance.recordError(
    error,
    stack,
    reason: '$code - $message',
    printDetails: printDetails,
  );
}
