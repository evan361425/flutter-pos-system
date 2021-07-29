import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../mocks/mock_widgets.dart';

void main() {
  test('should not fire onClick twice', () {
    final target = TargetFocus(identify: 'id', keyTarget: GlobalKey());
    var count = 0;
    final tutorial = Tutorial(
      MockBuildContext(),
      [],
      onClick: (_) => count++,
    );

    tutorial.handleClickTarget(target);
    expect(count, equals(1));
    tutorial.handleClickTarget(target);
    expect(count, equals(1));
  });
}
