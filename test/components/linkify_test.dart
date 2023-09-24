import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/helpers/launcher.dart';

void main() {
  group('Widget Linkify', () {
    testWidgets('should launch', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      const link = 'any-link';

      const LinkifyData('test', link).launch();

      expect(Launcher.lastUrl, equals(link));
    });
  });
}
