import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/tutorial.dart';

import '../mocks/mock_cache.dart';

void main() {
  group('Tutorial', () {
    testWidgets('should setup cache after tutorial', (tester) async {
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, true)).thenAnswer((_) => Future.value(true));

      final t1 = Tutorial.buildAnt();
      final widgets = Column(
        children: <Widget>[
          Tutorial(
            id: '1',
            title: 'title1',
            message: 'message1',
            fast: true,
            ant: t1,
            ants: [t1],
            child: const Text('1'),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: widgets),
      ));
      await tester.pumpAndSettle();

      // show spotlight
      await tester.pump(const Duration(milliseconds: 5));
      verify(cache.get('tutorial.1'));

      await tester.tapAt(const Offset(100, 100));
      verify(cache.set('tutorial.1', true));
    });
  });

  setUpAll(() {
    initializeCache();
  });
}
