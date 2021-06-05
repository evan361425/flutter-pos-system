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

void _log(String message, String code, Map<String, Object>? detail, int level) {
  developer.log(message, name: code);
  // no need send debug event
  if (level == 4) return;

  detail ??= {};
  detail['message'] = message;

  MyApp.analytics.logEvent(
    name: code,
    parameters: detail,
  );
}

/// level 4
void debug(String message, String code, [Map<String, Object>? detail]) {
  if (LOG_LEVEL > 3) {
    _log(message, code, detail, 4);
  }
}

/// level 3
void info(String message, String code, [Map<String, Object>? detail]) {
  if (LOG_LEVEL > 2) {
    _log(message, code, detail, 3);
  }
}

/// level 2
void warn(String message, String code, [Map<String, Object>? detail]) {
  if (LOG_LEVEL > 1) {
    _log(message, code, detail, 2);
  }
}

/// level 1
void error(String message, String code, [Map<String, Object>? detail]) {
  if (LOG_LEVEL != 0) {
    _log(message, code, detail, 1);
  }
}
