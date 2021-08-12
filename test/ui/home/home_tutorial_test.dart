import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/ui/home/home_tutorial.dart';

import '../../mocks/mock_widgets.dart';

void main() {
  test('should build success', () {
    HomeTutorial.steps(
      MockBuildContext(),
      TutorialName.go_menu,
      HomeTutorial.STEPS[TutorialName.go_menu]!,
    );
    HomeTutorial.steps(
      MockBuildContext(),
      TutorialName.introduce_features,
      HomeTutorial.STEPS[TutorialName.introduce_features]!,
    );
  });
}
