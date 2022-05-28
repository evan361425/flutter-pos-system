import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/loading_wrapper.dart';

void main() {
  group('Widget LoadingWrapper', () {
    testWidgets('should show status', (tester) async {
      final loader = GlobalKey<LoadingWrapperState>();
      await tester.pumpWidget(Material(
        child: MaterialApp(
          home: LoadingWrapper(
            key: loader,
            isLoading: true,
            child: const Text('hi'),
          ),
        ),
      ));

      loader.currentState?.setStatus('Hello World');
      await tester.pump();

      expect(find.text('Hello World'), findsOneWidget);
    });
  });
}
