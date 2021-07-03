import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

abstract class Tutorial {
  Function(TargetFocus)? onClick;

  final _clickedRecord = <String, bool>{};

  late final TutorialCoachMark _tutorialMark;

  final bool hideSkip;

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
      onClickTarget: handleClickTarget,
    );
  }

  List<TargetFocus> createTargets(
      BuildContext context, List<GlobalKey> targets);

  void finish() => _tutorialMark.finish();

  void next() => _tutorialMark.next();

  void show() => _tutorialMark.show();

  /// should fire once every target
  void handleClickTarget(target) {
    if (!_clickedRecord.containsKey(target.identify)) {
      _clickedRecord[target.identify] = true;
      onClick != null ? onClick!(target) : next();
    }
  }
}
