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

      Log.ger('hi', 'there', 'world', true);
      await tester.pumpAndSettle();

      expect(sentCount, equals(1));
    });

    testWidgets('Should do things on crashlytics', (tester) async {
      int counter = 0;
      await Firebase.initializeApp();
      MethodChannelFirebaseCrashlytics.channel
          .setMockMethodCallHandler((call) async {
        if (call.method == 'Crashlytics#setCrashlyticsCollectionEnabled') {
          return {};
        }

        counter++;
        return '';
      });
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);

      Log.err(Exception('hi'), 'there', null, true);
      await tester.pumpAndSettle();

      expect(counter, equals(1));
    });
  });
}
