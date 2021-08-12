import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../mocks/mock_cache.dart';
import '../mocks/mock_widgets.dart';

void main() {
  test('should not fire onClick twice', () {
    final key = GlobalKey();
    final target = TargetFocus(identify: 0, keyTarget: key);

    var count = 0;
    final tutorial = Tutorial(
      MockBuildContext(),
      [TutorialStep(onTap: () => count++, content: '', key: key)],
    );

    tutorial.handleClickTarget(target);
    expect(count, equals(1));
    tutorial.handleClickTarget(target);
    expect(count, equals(1));

    tutorial.next();
  });

  testWidgets('should fire on pop', (tester) async {
    final key = GlobalKey<_SomeTutorialState>();
    final widget = _SomeTutorial(key);
    when(cache.shouldCheckTutorial(any, any)).thenReturn(true);

    await tester.pumpWidget(MaterialApp(
      home: Navigator(
        onPopPage: (route, result) => route.didPop(result),
        pages: [
          MaterialPage(child: widget),
          MaterialPage(child: Container()),
        ],
      ),
    ));

    key.currentState?.pop();
    await tester.pumpAndSettle();

    expect(key.currentState?.count, equals(1));
  });

  setUpAll(() {
    initializeCache();
  });
}

class _SomeTutorial extends StatefulWidget {
  const _SomeTutorial(Key key) : super(key: key);

  @override
  _SomeTutorialState createState() => _SomeTutorialState();
}

class _SomeTutorialState extends State<_SomeTutorial>
    with RouteAware, TutorialAware<_SomeTutorial> {
  final textKey = GlobalKey();
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('content', key: textKey));
  }

  @override
  bool showTutorialIfNeed() {
    count++;
    return false;
  }

  void pop() => Navigator.of(context).pop();
}
