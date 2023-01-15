import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/tutorial.dart';

import '../mocks/mock_cache.dart';

void main() {
  group('Tutorial', () {
    testWidgets('three different tutorial', (tester) async {
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, true)).thenAnswer((_) => Future.value(true));

      final t2 = GlobalKey<State<Tutorial>>();
      final t3 = GlobalKey<State<Tutorial>>();
      final widgets = Column(
        children: <Widget>[
          Tutorial(
            id: '1',
            title: 'title1',
            message: 'message1',
            shape: TutorialShape.circle,
            align: TutorialAlign.bottom,
            animationDuration: const Duration(milliseconds: 10),
            targets: [Tutorial.self, t2, t3],
            child: const Text('1'),
          ),
          Tutorial(
            key: t2,
            id: '2',
            message: 'message2',
            shape: TutorialShape.rect,
            align: TutorialAlign.top,
            animationDuration: const Duration(milliseconds: 10),
            child: const Text('2'),
          ),
          Tutorial(
            key: t3,
            id: '3',
            message: 'message3',
            disable: true,
            child: const Text('3'),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: widgets),
      ));
      await tester.pumpAndSettle();

      Future<void> waitAnimation() async {
        await tester.pump(const Duration(milliseconds: 15));
        await tester.pump(const Duration(milliseconds: 15));
        await tester.pump(const Duration(milliseconds: 15));
      }

      // show
      await waitAnimation();

      await tester.tapAt(const Offset(100, 100));
      verify(cache.set('tutorial.1', true));

      // reverse
      await waitAnimation();
      // show
      await waitAnimation();

      await tester.tapAt(const Offset(100, 100));
      verify(cache.set('tutorial.2', true));

      await waitAnimation();
      await waitAnimation();

      await tester.tapAt(const Offset(100, 100));
      verifyNever(cache.set('tutorial.3', true));
    });

    testWidgets('with tab', (tester) async {
      when(cache.get(any)).thenReturn(null);
      when(cache.set(any, true)).thenAnswer((_) => Future.value(true));

      await tester.pumpWidget(MaterialApp(home: _TestTabViewer(
        builder: (controller) {
          return [
            Tutorial(
              id: 't1',
              title: 'title1',
              message: 'message1',
              animationDuration: const Duration(milliseconds: 10),
              targets: const [Tutorial.self],
              tab: TutorialInTab(controller: controller, index: 0),
              child: const Text('child1'),
            ),
            Tutorial(
              id: 't2',
              title: 'title2',
              message: 'message2',
              animationDuration: const Duration(milliseconds: 10),
              targets: const [Tutorial.self],
              tab: TutorialInTab(controller: controller, index: 1),
              child: const Text('child2'),
            ),
          ];
        },
      )));
      await tester.pumpAndSettle();

      Future<void> waitAnimation() async {
        await tester.pump(const Duration(milliseconds: 15));
        await tester.pump(const Duration(milliseconds: 15));
        await tester.pump(const Duration(milliseconds: 15));
      }

      // show
      await waitAnimation();

      await tester.tapAt(const Offset(100, 100));
      verify(cache.set('tutorial.t1', true));

      // reverse
      await waitAnimation();
      // show
      await waitAnimation();

      await tester.tapAt(const Offset(100, 100));
      verifyNever(cache.set('tutorial.t2', true));

      await tester.tap(find.text('tab2'));
      await tester.pumpAndSettle();

      await waitAnimation();

      await tester.tapAt(const Offset(100, 100));
      verify(cache.set('tutorial.t2', true));
    });
  });

  setUpAll(() {
    initializeCache();
  });
}

class _TestTabViewer extends StatefulWidget {
  final List<Widget> Function(TabController) builder;

  const _TestTabViewer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<_TestTabViewer> createState() => _TestTabViewerState();
}

class _TestTabViewerState extends State<_TestTabViewer>
    with SingleTickerProviderStateMixin {
  late final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: TabBar(
        controller: controller,
        tabs: const [
          Tab(text: 'tab1'),
          Tab(text: 'tab2'),
        ],
      ),
      body: TabBarView(
        controller: controller,
        children: widget.builder(controller),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: 2,
      vsync: this,
    );
  }
}
