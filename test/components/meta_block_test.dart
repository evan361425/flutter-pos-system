import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/meta_block.dart';

import '../mocks/mock_widgets.dart';

void main() {
  testWidgets('should get seperate between text', (WidgetTester tester) async {
    final context = MockBuildContext();
    final widget = MetaBlock.withString(context, ['123', '456', '789'])!;

    await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: widget));

    expect(find.byWidgetPredicate((text) {
      if (!(text is RichText)) return false;

      final buffer = StringBuffer();
      // ignore: invalid_use_of_protected_member
      text.text.computeToPlainText(buffer);
      return buffer.toString().split('•').length == 3;
    }), findsOneWidget);
  });

  testWidgets('should get default text', (WidgetTester tester) async {
    final context = MockBuildContext();
    final widget = MetaBlock.withString(context, [], emptyText: 'default')!;

    await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: widget));

    expect(find.byWidgetPredicate((text) {
      if (!(text is RichText)) return false;

      final buffer = StringBuffer();
      // ignore: invalid_use_of_protected_member
      text.text.computeToPlainText(buffer);
      return buffer.toString().contains('default');
    }), findsOneWidget);
  });
}
