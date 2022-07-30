import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

const _isDebug = kDebugMode || String.fromEnvironment('appFlavor') == 'debug';

class Log {
  static void out(String msg, String code) {
    developer.log(msg, name: code);
  }

  static void ger(
    String action,
    String code, [
    String? message,
    @visibleForTesting bool forceSend = false,
  ]) {
    assert(!code.contains('.'));
    if (message != null) {
      developer.log('$action - $message', name: code);
    } else {
      developer.log(action, name: code);
    }

    if (forceSend || allowSendEvents) {
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
  static set allowSendEvents(bool value) =>
      _allowSendEvents = _isDebug ? false : value;

  @visibleForTesting
  static int errorCount = 0;
}
