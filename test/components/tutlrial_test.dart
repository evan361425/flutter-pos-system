import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
  });
}
