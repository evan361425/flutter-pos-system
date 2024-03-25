import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/ui/analysis/widgets/chart_range_page.dart';

import '../../../test_helpers/translator.dart';

void main() {
  group('Chart Range Page', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final range = DateTimeRange(
        start: today.subtract(const Duration(days: 7)),
        end: today,
      );
      final format = DateFormat.MMMd('zh_TW');

      DateTimeRange? selected;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(
          body: Builder(builder: (context) {
            return TextButton(
              child: const Text('go'),
              onPressed: () async {
                selected = await Navigator.of(context).push<DateTimeRange>(
                  MaterialPageRoute(
                    builder: (context) => ChartRangePage(range: range),
                  ),
                );
              },
            );
          }),
        )),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.text('最近7日'), findsOneWidget);
      expect(find.text(range.format(format)), findsAtLeastNWidgets(1));
      expect(find.text('本週'), findsOneWidget);
      expect(find.text('上週'), findsOneWidget);

      await tester.tap(find.text('日期'));
      await tester.pumpAndSettle();

      expect(find.text('昨日'), findsOneWidget);
      await tester.tap(find.text('今日'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('月'));
      await tester.pumpAndSettle();

      expect(find.text('最近30日'), findsOneWidget);
      expect(find.text('本月'), findsOneWidget);
      expect(find.text('上月'), findsOneWidget);

      await tester.tap(find.text('自訂'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.text(DateTimeRange(start: today, end: tomorrow).format(format)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(selected, DateTimeRange(start: today, end: tomorrow));
    });
  });

  setUpAll(() {
    initializeTranslator();
  });
}
