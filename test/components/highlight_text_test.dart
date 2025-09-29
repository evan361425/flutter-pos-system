import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/style/highlight_text.dart';

void main() {
  group('HighlightText', () {
    testWidgets('should display text without highlighting when pattern is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightText(
              text: 'Hello World',
              pattern: '',
            ),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should highlight single word match', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightText(
              text: 'Hello World',
              pattern: 'Hello',
            ),
          ),
        ),
      );

      final richText = tester.widget<Text>(find.byType(Text));
      final textSpan = richText.textSpan as TextSpan;
      
      expect(textSpan.children, hasLength(2));
      // First span should be highlighted "Hello"
      expect(textSpan.children![0].toPlainText(), equals('Hello'));
      // Second span should be regular " World"
      expect(textSpan.children![1].toPlainText(), equals(' World'));
    });

    testWidgets('should highlight multiple word matches', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightText(
              text: 'Hello Beautiful World',
              pattern: 'Hello World',
            ),
          ),
        ),
      );

      final richText = tester.widget<Text>(find.byType(Text));
      final textSpan = richText.textSpan as TextSpan;
      
      expect(textSpan.children, hasLength(4));
      // Should have: "Hello", " Beautiful ", "World"
      expect(textSpan.children![0].toPlainText(), equals('Hello'));
      expect(textSpan.children![1].toPlainText(), equals(' Beautiful '));
      expect(textSpan.children![2].toPlainText(), equals('World'));
    });

    testWidgets('should be case insensitive', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightText(
              text: 'Hello World',
              pattern: 'hello',
            ),
          ),
        ),
      );

      final richText = tester.widget<Text>(find.byType(Text));
      final textSpan = richText.textSpan as TextSpan;
      
      expect(textSpan.children, hasLength(2));
      // First span should be highlighted "Hello" (original case preserved)
      expect(textSpan.children![0].toPlainText(), equals('Hello'));
      expect(textSpan.children![1].toPlainText(), equals(' World'));
    });

    testWidgets('should handle overlapping matches', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightText(
              text: 'banana',
              pattern: 'an ana',
            ),
          ),
        ),
      );

      final richText = tester.widget<Text>(find.byType(Text));
      final textSpan = richText.textSpan as TextSpan;
      
      // Should merge overlapping matches
      expect(textSpan.children, hasLength(2));
      expect(textSpan.children![0].toPlainText(), equals('b'));
      expect(textSpan.children![1].toPlainText(), equals('anana'));
    });

    testWidgets('should apply custom styles', (tester) async {
      const customStyle = TextStyle(fontSize: 20);
      const customHighlightStyle = TextStyle(color: Colors.red);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightText(
              text: 'Hello World',
              pattern: 'Hello',
              style: customStyle,
              highlightStyle: customHighlightStyle,
            ),
          ),
        ),
      );

      final richText = tester.widget<Text>(find.byType(Text));
      final textSpan = richText.textSpan as TextSpan;
      
      // Check that highlighted span has custom highlight style
      final highlightedSpan = textSpan.children![0] as TextSpan;
      expect(highlightedSpan.style, equals(customHighlightStyle));
    });
  });
}