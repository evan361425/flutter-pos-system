// ignore: depend_on_referenced_packages
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/src/pigeon/messages.pigeon.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/src/pigeon/mocks.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/src/pigeon/test_api.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_auth/firebase_auth/test/mock.dart
void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
}

// https://github.com/firebase/flutterfire/blob/master/packages/firebase_crashlytics/firebase_crashlytics/test/mock.dart
MockCrashlytics setupFirebaseCrashlyticsMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final crashlytics = MockCrashlytics();
  TestFirebaseCoreHostApi.setup(crashlytics);

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(MethodChannelFirebaseCrashlytics.channel, (c) async {
    crashlytics.methodCalls.add(c.method);
    return null;
  });

  return crashlytics;
}

// https://github.com/firebase/flutterfire/blob/master/packages/firebase_analytics/firebase_analytics/test/mock.dart
Map<String, List<String>> setupFirebaseAnalyticsMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();

  final record = <String, List<String>>{'methods': []};
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(MethodChannelFirebaseAnalytics.channel, (c) async {
    record['methods']!.add(c.method);
    return false;
  });

  return record;
}

class MockCrashlytics implements TestFirebaseCoreHostApi {
  List<String> methodCalls = [];

  @override
  Future<PigeonInitializeResponse> initializeApp(
    String appName,
    PigeonFirebaseOptions initializeAppRequest,
  ) async {
    return PigeonInitializeResponse(
      name: appName,
      options: PigeonFirebaseOptions(
        apiKey: '123',
        projectId: '123',
        appId: '123',
        messagingSenderId: '123',
      ),
      pluginConstants: {
        'plugins.flutter.io/firebase_crashlytics': {'isCrashlyticsCollectionEnabled': false}
      },
    );
  }

  @override
  Future<List<PigeonInitializeResponse?>> initializeCore() async {
    return [
      PigeonInitializeResponse(
        name: defaultFirebaseAppName,
        options: PigeonFirebaseOptions(
          apiKey: '123',
          projectId: '123',
          appId: '123',
          messagingSenderId: '123',
        ),
        pluginConstants: {
          'plugins.flutter.io/firebase_crashlytics': {'isCrashlyticsCollectionEnabled': false}
        },
      )
    ];
  }

  @override
  Future<PigeonFirebaseOptions> optionsFromResource() async {
    return PigeonFirebaseOptions(
      apiKey: '123',
      projectId: '123',
      appId: '123',
      messagingSenderId: '123',
    );
  }
}
