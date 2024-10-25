import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/helpers/analysis/ema_calculator.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/ui/analysis/widgets/goals_card_view.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../mocks/mock_cache.dart';
import '../../../mocks/mock_database.dart';
import '../../../test_helpers/translator.dart';

void main() {
  Future<List<Map<String, Object?>>> mockQuery(int begin, int cease) {
    return database.query(
      argThat(contains('createdAt BETWEEN $begin AND $cease')),
      columns: anyNamed('columns'),
      groupBy: anyNamed('groupBy'),
      orderBy: anyNamed('orderBy'),
      limit: anyNamed('limit'),
      escapeTable: anyNamed('escapeTable'),
    );
  }

  group('Goals View', () {
    testWidgets('EMA calculator should work correctly', (tester) async {
      final today = Util.toUTC(hour: 0);
      final tomorrow = today + 86400;
      final fortyDaysAgo = today - 86400 * 40;

      when(mockQuery(fortyDaysAgo, tomorrow)).thenAnswer((_) async => [
            for (var i = 20; i >= 0; i--)
              {
                'day': 20 + i,
                'count': i,
                'revenue': i * 1.1,
                'profit': i * 1.2,
                'cost': i * 1.3,
              }
          ]);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: GoalsCardView()),
      ));
      await tester.pumpAndSettle();

      void findText(String v) {
        expect(find.text(v, findRichText: true), findsOneWidget);
      }

      const calculator = EMACalculator(20);
      final data = <String, num>{
        'count': calculator.calculate([for (var i = 0; i < 20; i++) i]),
        'revenue': calculator.calculate([for (var i = 0; i < 20; i++) i * 1.1]),
        'profit': calculator.calculate([for (var i = 0; i < 20; i++) i * 1.2]),
      };
      findText('20／${data['count']!.toInt()}');
      findText('22／${data['revenue']!.toCurrency()}');
      findText('24／${data['profit']!.toCurrency()}');
      verify(mockQuery(fortyDaysAgo, tomorrow));

      // notify the seller to update the view
      when(mockQuery(today, tomorrow)).thenAnswer((_) => Future.value([
            {
              'day': 0,
              'count': 2,
              'profit': 2.1,
              'revenue': 2.2,
              'cost': 2.3,
            }
          ]));
      Seller.instance.notifyListeners();
      await tester.pumpAndSettle();

      findText('2／${data['count']!.toInt()}');
      verify(mockQuery(today, tomorrow));
      verifyNever(mockQuery(fortyDaysAgo, tomorrow));
    });

    setUp(() {
      when(cache.get('analysis.goals')).thenReturn(true);
    });

    setUpAll(() {
      initializeDatabase();
      initializeCache();
      initializeTranslator();
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
    });
  });
}
