import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';

import '../test_helpers/firebase_mocker.dart';

void main() {
  group('Logger', () {
    setupFirebaseAuthMocks();

    testWidgets('Should do things on analytics', (tester) async {
      await Firebase.initializeApp();
      var sentCount = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_analytics'),
        (MethodCall methodCall) async {
          sentCount++;
          return '';
        },
      );

      // FirebaseCrashlyticsPlatform.instanceFor(
      //     app: app, pluginConstants: {'isCrashlyticsCollectionEnabled': false});
      // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      debug('hi', 'there', {'a': 'b'});
      info('hi', 'there');
      warn('hi', 'there');
      await waitLog('hi', 'there');
      expect(sentCount, equals(4));
    });

    testWidgets('Should do things on crashlytics', (tester) async {
      await Firebase.initializeApp();
      MethodChannelFirebaseCrashlytics.channel
          .setMockMethodCallHandler((call) async {
        if (call.method == 'Crashlytics#setCrashlyticsCollectionEnabled') {
          return {};
        }

        return '';
      });
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);

      await error('hi', 'there', null, false);
    });

    setUpAll(() {
      logLevel = 5;
    });

    tearDownAll(() {
      logLevel = 4;
    });
  });
}
