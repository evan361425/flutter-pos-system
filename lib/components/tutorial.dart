import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

abstract class Tutorial {
  Function(TargetFocus)? onClick;
  Tutorial(
    BuildContext context,
    List<GlobalKey> targets, {
    this.hideSkip = true,
    this.onClick,
  }) {
    final color = Theme.of(context).primaryColor;

    _tutorialMark = TutorialCoachMark(
      context,
      targets: createTargets(context, targets),
      colorShadow: color, // DEFAULT Colors.black
      opacityShadow: 0.8,
      hideSkip: hideSkip,
      onClickTarget: (target) {
        if (_isFirstClicked(target)) {
          onClick != null ? onClick!(target) : next();
        }
      },
    );
  }

  final _clickedRecord = <String, bool>{};

  bool _isFirstClicked(TargetFocus target) {
    if (_clickedRecord.containsKey(target.identify)) return false;

    _clickedRecord[target.identify] = true;
    return true;
  }

  void show() => _tutorialMark.show();

  void finish() => _tutorialMark.finish();

  void next() => _tutorialMark.next();

  late final TutorialCoachMark _tutorialMark;

  final bool hideSkip;

  List<TargetFocus> createTargets(
      BuildContext context, List<GlobalKey> targets);
}
