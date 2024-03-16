import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/ui/analysis/widgets/reloadable_card.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  group('Component AnalysisCard', () {
    testWidgets('show error', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ReloadableCard(
          id: 'test',
          builder: (context, metric) => const SizedBox.shrink(),
          loader: () => Future.error('test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('only reload after shown', (tester) async {
      int loadCount = 0;
      final notifier = ValueNotifier('val1');
      // https://pub.dev/packages/visibility_detector#widget-tests
      VisibilityDetectorController.instance.updateInterval = Duration.zero;

      await tester.pumpWidget(MaterialApp(
        home: ReloadableCard<String>(
          id: 'test',
          notifiers: [notifier],
          builder: (context, metric) => TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('next page'),
                );
              }));
            },
            child: Text(metric),
          ),
          loader: () {
            loadCount++;
            return Future.value(notifier.value);
          },
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text(notifier.value), findsOneWidget);
      expect(loadCount, equals(1));

      await tester.tap(find.text(notifier.value));
      await tester.pumpAndSettle();

      expect(find.text('next page'), findsOneWidget);
      notifier.value = 'val2';

      await tester.pumpAndSettle();
      expect(loadCount, equals(1));

      await tester.tap(find.text('next page'));
      await tester.pumpAndSettle();

      expect(find.text(notifier.value), findsOneWidget);
      expect(loadCount, equals(2));
    });
  });
}
