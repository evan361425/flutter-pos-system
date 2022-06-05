import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

const _isDebug = kDebugMode || String.fromEnvironment('appFlavor') == 'debug';

class Log {
  static void ger(
    String action,
    String code, [
    String? message,
    @visibleForTesting bool forceSend = false,
  ]) {
    assert(!code.contains('.'));
    developer.log(action, name: code);
    if (message != null) {
      developer.log('$action - $message', name: code);
    }

    // no need send debug event
    if (forceSend || !_isDebug) {
      FirebaseAnalytics.instance.logEvent(
        name: '${code}_$action',
        parameters: message != null ? {'message': message} : null,
      );
    }
  }

  static void err(
    Object error,
    String code, [
    StackTrace? stackTrace,
    @visibleForTesting bool forceSend = false,
  ]) {
    assert(!code.contains('.'));
    assert(() {
      errorCount++;
      return true;
    }());
    developer.log(
      error.toString(),
      name: code,
      error: error,
      stackTrace: stackTrace,
    );

    if (forceSend || !_isDebug) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: code,
      );
    }
  }

  @visibleForTesting
  static int errorCount = 0;
}
