import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/search_bar.dart';
import 'package:possystem/constants/icons.dart';

void main() {
  group('Widget SearchBar', () {
    testWidgets('should show cancel in texting', (WidgetTester tester) async {
      late String currentText;
      final searchBar = SearchBar(onChanged: (text) => currentText = text);

      await tester.pumpWidget(Material(child: MaterialApp(home: searchBar)));
      await tester.enterText(find.byType(TextField), 'hello world');
      await tester.pumpAndSettle();

      expect(currentText, equals('hello world'));
      await tester.tap(find.byIcon(KIcons.clear));
      await tester.pumpAndSettle();

      expect(currentText, isEmpty);
      expect(find.byIcon(KIcons.clear), findsNothing);
    });
  });
}
