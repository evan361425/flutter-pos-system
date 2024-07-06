import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

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

    testWidgets('should show in tab view', (tester) async {
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, true)).thenAnswer((_) => Future.value(true));
      final show = GlobalKey<SpotlightShowState>();

      await tester.pumpWidget(MaterialApp(
        home: TutorialWrapper(key: show, child: const _Scaffold()),
      ));
      await tester.pumpAndSettle();

      // show spotlight
      await tester.pump(const Duration(milliseconds: 5));
      verify(cache.get('tutorial.1'));

      await tester.tapAt(const Offset(100, 100));
      await tester.pump(const Duration(milliseconds: 5));
      verify(cache.set('tutorial.1', true));

      // go to tab 2
      await tester.tap(find.byKey(const Key('t2')));
      await tester.pump(const Duration(milliseconds: 100));
      verify(cache.get('tutorial.2'));

      // show spotlight
      await tester.pump(const Duration(milliseconds: 5));
      await tester.pump(const Duration(milliseconds: 5));
      await tester.pump(const Duration(milliseconds: 5));
      await tester.tapAt(const Offset(100, 100));
      await tester.pump(const Duration(milliseconds: 5));
      verify(cache.set('tutorial.2', true));

      // go back to tab 1
      await tester.tap(find.byKey(const Key('t1')));
      await tester.pump(const Duration(milliseconds: 100));

      // should not fire again
      expect(show.currentState, isNull);
    });
  });

  setUpAll(() {
    Tutorial.debug = true;
    initializeCache();
  });
}

class _Scaffold extends StatefulWidget {
  const _Scaffold();

  @override
  State<_Scaffold> createState() => _ScaffoldState();
}

class _ScaffoldState extends State<_Scaffold> with TickerProviderStateMixin {
  late final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: TabBar(
        controller: controller,
        tabs: const [
          Tab(key: Key('t1'), text: 't1'),
          Tab(key: Key('t2'), text: 't2'),
        ],
      ),
      body: TabBarView(
        controller: controller,
        children: <Widget>[
          TutorialWrapper(
            tab: TutorialInTab(controller: controller, index: 0),
            child: const Tutorial(
              id: '1',
              title: 'title1',
              message: 'message1',
              child: Text('1'),
            ),
          ),
          TutorialWrapper(
            tab: TutorialInTab(controller: controller, index: 1),
            child: const Tutorial(
              id: '2',
              title: 'title2',
              message: 'message2',
              child: Text('2'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    controller = TabController(
      animationDuration: Duration.zero,
      length: 2,
      vsync: this,
    );
    super.initState();
  }
}
