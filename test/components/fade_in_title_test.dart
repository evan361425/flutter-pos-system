import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/scaffold/fade_in_title_scaffold.dart';

void main() {
  group('Widget FadeInTitle', () {
    testWidgets('should show after scroll', (WidgetTester tester) async {
      final widget = MaterialApp(
        home: FadeInTitleScaffold(
          title: 'hi',
          body: Column(children: [
            for (var i = 0; i < 30; i++) ListTile(title: Text(i.toString()))
          ]),
        ),
      );
      await tester.pumpWidget(widget);

      var finder = find.byType(AnimatedOpacity);
      expect(finder, findsOneWidget);
      var title = tester.firstWidget<AnimatedOpacity>(finder);

      // check it is hiding
      expect(title.opacity, equals(0));

      // drag to bottom
      await tester.drag(find.text('1'), const Offset(0, -800));
      await tester.pumpAndSettle();

      // check it is showing
      finder = find.byType(AnimatedOpacity);
      expect(finder, findsOneWidget);
      title = tester.firstWidget<AnimatedOpacity>(finder);
      expect(title.opacity, equals(1));
    });
  });
}
