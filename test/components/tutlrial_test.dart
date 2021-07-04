import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void main() {
  test('should not fire onClick twice', () {
    final target = TargetFocus(identify: 'id', keyTarget: GlobalKey());
    var count = 0;
    final tutorial = TestTutorial(
      _MockBuildContext(),
      (_) => count++,
    );

    tutorial.handleClickTarget(target);
    expect(count, equals(1));
    tutorial.handleClickTarget(target);
    expect(count, equals(1));
  });
}

class TestTutorial extends Tutorial {
  TestTutorial(BuildContext context, void Function(TargetFocus) onClick)
      : super(context, [], onClick: onClick);

  @override
  List<TargetFocus> createTargets(_, __) => [];
}

class _MockBuildContext extends Mock implements BuildContext {}
