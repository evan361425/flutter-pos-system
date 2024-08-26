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

      const widgets = Column(
        children: <Widget>[
          Tutorial(
            id: '1',
            title: 'title1',
            message: 'message1',
            child: Text('1'),
          ),
        ],
      );

      await tester.pumpWidget(const MaterialApp(
        home: TutorialWrapper(child: Scaffold(body: widgets)),
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
    Tutorial.debug = true;
    initializeCache();
  });
}
