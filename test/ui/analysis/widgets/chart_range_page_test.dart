import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/analysis/widgets/chart_range_page.dart';

import '../../../test_helpers/breakpoint_mocker.dart';
import '../../../test_helpers/translator.dart';

void main() {
  group('Chart Range Page', () {
    for (final device in [Device.mobile, Device.desktop]) {
      group(device.name, () {
        testWidgets('renders correctly', (WidgetTester tester) async {
          deviceAs(device, tester);
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final tomorrow = today.add(const Duration(days: 1));
          final range = DateTimeRange(
            start: today.subtract(const Duration(days: 7)),
            end: today,
          );

          DateTimeRange? selected;
          await tester.pumpWidget(
            MaterialApp.router(
              routerConfig: GoRouter(navigatorKey: Routes.rootNavigatorKey, routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
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
                  ),
                ),
              ]),
            ),
          );
          await tester.tap(find.text('go'));
          await tester.pumpAndSettle();

          expect(find.text(S.analysisChartRangeLast7Days), findsOneWidget);
          expect(find.text(range.format('en')), findsAtLeastNWidgets(1));
          expect(find.text(S.analysisChartRangeThisWeek), findsOneWidget);
          expect(find.text(S.analysisChartRangeLastWeek), findsOneWidget);

          await tester.tap(find.text(S.analysisChartRangeTabName('day')));
          await tester.pumpAndSettle();

          expect(find.text(S.analysisChartRangeYesterday), findsOneWidget);
          await tester.tap(find.text(S.analysisChartRangeToday));
          await tester.pumpAndSettle();

          await tester.tap(find.text(S.analysisChartRangeTabName('month')));
          await tester.pumpAndSettle();

          expect(find.text(S.analysisChartRangeLast30Days), findsOneWidget);
          expect(find.text(S.analysisChartRangeThisMonth), findsOneWidget);
          expect(find.text(S.analysisChartRangeLastMonth), findsOneWidget);

          // only test in mobile, because desktop's select range is still unknown
          if (device == Device.mobile) {
            await tester.tap(find.text(S.analysisChartRangeTabName('custom')));
            await tester.pumpAndSettle();

            await tester.tap(
              find.text(DateTimeRange(start: today, end: tomorrow).format('en')),
            );
            // No idea why we have to tap twice. I've tried to pumpAndSettle
            // several times, but it still doesn't work
            await tester.pumpAndSettle();
            await tester.tap(find.text('OK'), warnIfMissed: false);
            await tester.pumpAndSettle();
            await tester.tap(find.text('OK'));
            await tester.pumpAndSettle();

            expect(selected, DateTimeRange(start: today, end: tomorrow));
          }
        });
      });
    }
  });

  setUpAll(() {
    initializeTranslator();
  });
}
