import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/scrollable_draggable_sheet.dart';

void main() {
  group('Component ScrollableDraggableSheet', () {
    testWidgets('reset before pop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Builder(builder: (context) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return Scaffold(
                      body: ScrollableDraggableSheet(
                        indicator: const DraggableIndicator(key: Key('t')),
                        snapSizes: const [0.1, 1.0],
                        builder: (controller, scroll, _) {
                          return [
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scroll,
                                child: const ListTile(title: Text('title')),
                              ),
                            ),
                          ];
                        },
                      ),
                    );
                  },
                ));
              },
              child: const Text('Go'),
            );
          })),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('title')).dy, equals(588));

      await tester.drag(find.byKey(const Key('t')), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.text('title')).dy, equals(48));

      // pop
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pump();

      // only reset the sheet
      expect(tester.getCenter(find.text('title')).dy, equals(588));
    });

    testWidgets('quickly drag without over half', (tester) async {
      late ScrollableDraggableController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollableDraggableSheet(
              indicator: const DraggableIndicator(key: Key('t')),
              snapSizes: const [0.1, 1.0],
              builder: (c, scroll, _) {
                controller = c;
                return [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scroll,
                      child: const ListTile(title: Text('title')),
                    ),
                  ),
                ];
              },
            ),
          ),
        ),
      );

      await tester.timedDrag(
        find.byKey(const Key('t')),
        const Offset(0, -100),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();

      expect(controller.snapIndex.value, equals(1));

      await tester.timedDrag(
        find.byKey(const Key('t')),
        const Offset(0, 100),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();

      expect(controller.snapIndex.value, equals(0));

      // over drag will not happen any error
      await tester.timedDrag(
        find.byKey(const Key('t')),
        const Offset(0, 100),
        const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();

      expect(controller.snapIndex.value, equals(0));
    });
  });
}
