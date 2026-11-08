// ignore: depend_on_referenced_packages
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_crashlytics_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final FakeFirebaseCrashlyticsHostApi hostApi = FakeFirebaseCrashlyticsHostApi();

// https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_auth/firebase_auth/test/mock.dart
void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
}

// https://github.com/firebase/flutterfire/blob/master/packages/firebase_crashlytics/firebase_crashlytics/test/mock.dart
void setupFirebaseCrashlyticsMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestFirebaseCoreHostApi.setUp(MockFirebaseAppWithCollectionEnabled());
  TestFirebaseCrashlyticsHostApi.setUp(hostApi);
}

// https://github.com/firebase/flutterfire/blob/master/packages/firebase_analytics/firebase_analytics/test/mock.dart
void setupFirebaseAnalyticsMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    MethodChannelFirebaseAnalytics.channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Analytics#getAppInstanceId':
          return 'ABCD1234';

        default:
          return false;
      }
    },
  );
}

class MockFirebaseAppWithCollectionEnabled implements TestFirebaseCoreHostApi {
  @override
  Future<CoreInitializeResponse> initializeApp(String appName, CoreFirebaseOptions initializeAppRequest) async {
    return CoreInitializeResponse(
      name: appName,
      options: CoreFirebaseOptions(apiKey: '123', projectId: '123', appId: '123', messagingSenderId: '123'),
      pluginConstants: {
        'plugins.flutter.io/firebase_crashlytics': {'isCrashlyticsCollectionEnabled': true},
      },
    );
  }

  @override
  Future<List<CoreInitializeResponse>> initializeCore() async {
    return [
      CoreInitializeResponse(
        name: defaultFirebaseAppName,
        options: CoreFirebaseOptions(apiKey: '123', projectId: '123', appId: '123', messagingSenderId: '123'),
        pluginConstants: {
          'plugins.flutter.io/firebase_crashlytics': {'isCrashlyticsCollectionEnabled': true},
        },
      ),
    ];
  }

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async {
    return CoreFirebaseOptions(apiKey: '123', projectId: '123', appId: '123', messagingSenderId: '123');
  }
}

class FakeFirebaseCrashlyticsHostApi implements TestFirebaseCrashlyticsHostApi {
  final List<String> calls = <String>[];
  RecordErrorRequest? lastRecordError;
  String? lastLogMessage;
  bool? lastCollectionEnabled;
  String? lastUserIdentifier;
  String? lastCustomKey;
  String? lastCustomValue;

  void reset() {
    calls.clear();
    lastRecordError = null;
    lastLogMessage = null;
    lastCollectionEnabled = null;
    lastUserIdentifier = null;
    lastCustomKey = null;
    lastCustomValue = null;
  }

  @override
  Future<bool> checkForUnsentReports() async {
    calls.add('checkForUnsentReports');
    return true;
  }

  @override
  Future<void> crash() async {
    calls.add('crash');
  }

  @override
  Future<void> deleteUnsentReports() async {
    calls.add('deleteUnsentReports');
  }

  @override
  Future<bool> didCrashOnPreviousExecution() async {
    calls.add('didCrashOnPreviousExecution');
    return true;
  }

  @override
  Future<void> recordError(RecordErrorRequest request) async {
    calls.add('recordError');
    lastRecordError = request;
  }

  @override
  Future<void> log(String message) async {
    calls.add('log');
    lastLogMessage = message;
  }

  @override
  Future<void> sendUnsentReports() async {
    calls.add('sendUnsentReports');
  }

  @override
  Future<bool> setCrashlyticsCollectionEnabled(bool enabled) async {
    calls.add('setCrashlyticsCollectionEnabled');
    lastCollectionEnabled = enabled;
    return enabled;
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    calls.add('setUserIdentifier');
    lastUserIdentifier = identifier;
  }

  @override
  Future<void> setCustomKey(String key, String value) async {
    calls.add('setCustomKey');
    lastCustomKey = key;
    lastCustomValue = value;
  }
}
