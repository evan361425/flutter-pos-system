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

    testWidgets('mailto and http should be ok', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();

      final widget = Linkify.fromString('''
        and [Hello Mail](mailto:abc@mail.com)
        and [Hello HTTP](http://example.com)
        and [Hello HTTPS](https://example.com)
      ''');
      final data = widget.data.toList();

      expect(data[1].link, equals('mailto:abc@mail.com'));
      expect(data[1].text, equals('Hello Mail'));
      expect(data[3].link, equals('http://example.com'));
      expect(data[3].text, equals('Hello HTTP'));
      expect(data[5].link, equals('https://example.com'));
      expect(data[5].text, equals('Hello HTTPS'));
    });
  });
}
