import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Tutorial {
  Function(TargetFocus)? onClick;

  final _clickedRecord = <String, bool>{};

  late final TutorialCoachMark _tutorialMark;

  final bool hideSkip;

  Tutorial(
    BuildContext context,
    List<TutorialStep> steps, {
    this.hideSkip = true,
    this.onClick,
  }) {
    final style = TextStyle(color: Colors.white);

    var count = 0;

    final targets = steps.map((step) {
      return TargetFocus(
        identify: '_tutorial.${count++}',
        keyTarget: step.key,
        enableOverlayTab: onClick == null,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (step.title != null)
                    Text(
                      step.title!,
                      style: style.copyWith(fontSize: 24),
                    ),
                  Text(step.content, style: style),
                ],
              ),
            ),
          )
        ],
      );
    }).toList();

    _tutorialMark = TutorialCoachMark(
      context,
      targets: targets,
      hideSkip: hideSkip,
      onClickTarget: handleClickTarget,
    );
  }

  void finish() => _tutorialMark.finish();

  /// should fire once every target
  void handleClickTarget(target) {
    if (!_clickedRecord.containsKey(target.identify)) {
      _clickedRecord[target.identify] = true;
      onClick != null ? onClick!(target) : next();
    }
  }

  void next() => _tutorialMark.next();

  void show() => _tutorialMark.show();
}

class TutorialStep {
  final GlobalKey key;

  final String? title;

  final String content;

  const TutorialStep({
    required this.key,
    this.title,
    required this.content,
  });
}
