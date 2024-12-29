import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/logger.dart';

import '../test_helpers/firebase_mocker.dart';

void main() {
  group('Logger', () {
    testWidgets('Should do things on crashlytics', (tester) async {
      final crashlytics = setupFirebaseCrashlyticsMocks();
      await Firebase.initializeApp();

      Log.err(Exception('hi'), 'there', null, true);
      await tester.pumpAndSettle();

      expect(crashlytics.methodCalls[0], equals('Crashlytics#recordError'));
    });

    testWidgets('Should do things on analytics', (tester) async {
      final analytics = setupFirebaseAnalyticsMocks();
      await Firebase.initializeApp();

      Log.ger('hi', {'test': '1', 'key': 2}, true);
      await tester.pumpAndSettle();

      expect(analytics['methods']![0], equals('Analytics#logEvent'));
    });
  });
}
