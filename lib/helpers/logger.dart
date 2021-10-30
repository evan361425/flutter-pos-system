import 'dart:developer' as developer;

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:possystem/my_app.dart';

const _levelMap = {
  'debug': 4,
  'info': 3,
  'warn': 2,
  'error': 1,
};
const _level = String.fromEnvironment('LOG_LEVEL', defaultValue: 'info');
// allow editing in unit test
var logLevel = _levelMap[_level] ?? 3;

Future<void> _log(
    String message, String code, Map<String, Object>? detail, int level) async {
  developer.log(message, name: code);
  // no need send debug event
  if (level == 4) return;

  detail ??= {};
  detail['message'] = message;

  await MyApp.analytics.logEvent(
    name: code.split('.').join('_'),
    parameters: detail,
  );
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
/// It will send to crashlytic not analytic
Future<void> error(String message, String code, [StackTrace? stack]) async {
  if (logLevel != 0) {
    developer.log(message, name: code);
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: '$code - $message',
    );
  }
}
