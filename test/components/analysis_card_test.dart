import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/ui/analysis/widgets/analysis_card.dart';

void main() {
  group('Component AnalysisCard', () {
    testWidgets('show error', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AnalysisCard(
          builder: (context, metric) => const SizedBox.shrink(),
          loader: () => Future.error('test'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('test'), findsOneWidget);
    });
  });
}
