import 'dart:developer' as developer;

import 'package:possystem/my_app.dart';

const _LEVEL_MAP = {
  'debug': 4,
  'info': 3,
  'warn': 2,
  'error': 1,
};
const _LEVEL = String.fromEnvironment('LOG_LEVEL', defaultValue: 'info');
// allow editing in unit test
var LOG_LEVEL = _LEVEL_MAP[_LEVEL] ?? 3;

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

/// level 4
void debug(String message, String code, [Map<String, Object>? detail]) async {
  if (LOG_LEVEL > 3) {
    await _log(message, code, detail, 4);
  }
}

/// level 3
void info(String message, String code, [Map<String, Object>? detail]) async {
  if (LOG_LEVEL > 2) {
    await _log(message, code, detail, 3);
  }
}

/// level 2
void warn(String message, String code, [Map<String, Object>? detail]) async {
  if (LOG_LEVEL > 1) {
    await _log(message, code, detail, 2);
  }
}

/// level 1
void error(String message, String code, [Map<String, Object>? detail]) async {
  if (LOG_LEVEL != 0) {
    await _log(message, code, detail, 1);
  }
}
