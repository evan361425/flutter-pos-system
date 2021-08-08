import 'package:flutter/material.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/services/cache.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Tutorial {
  final List<TutorialStep> steps;

  late final TutorialCoachMark _tutorialMark;

  final bool showSkip;

  final Alignment skipAlignment;

  Tutorial(
    BuildContext context,
    this.steps, {
    this.showSkip = true,
    this.skipAlignment = Alignment.bottomRight,
  }) {
    final style = TextStyle(color: Colors.white);

    var count = 0;

    final targets = [
      for (var step in steps)
        TargetFocus(
          identify: count++,
          keyTarget: step.key,
          enableOverlayTab: step.onTap == null,
          alignSkip: step.skipAlignment,
          shape: step.shape,
          contents: [
            TargetContent(
              align: step.contentAlignment,
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
        )
    ];

    _tutorialMark = TutorialCoachMark(
      context,
      targets: targets,
      hideSkip: !showSkip,
      alignSkip: skipAlignment,
      onClickTarget: handleClickTarget,
    );
  }

  void finish() => _tutorialMark.finish();

  /// should fire once every target
  void handleClickTarget(TargetFocus target) {
    final index = target.identify as int;
    final step = steps[index];
    if (!step.isTapped) {
      step.onTap != null ? step.onTap!() : next();
      step.isTapped = true;
    }
  }

  void next() => _tutorialMark.next();

  void show() => _tutorialMark.show();
}

mixin TutorialAware<T extends StatefulWidget> on State<T>, RouteAware {
  Tutorial? tutorial;

  final String tutorialName = '';

  final int tutorialVersion = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MyApp.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    _showTutorialIfNeed();
  }

  @override
  void didPush() {
    _showTutorialIfNeed();
  }

  @override
  void dispose() {
    tutorial?.finish();
    MyApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Show tutorial if needed
  ///
  /// return true if and only if all proccess is checked to be done
  bool showTutorialIfNeed();

  void _showTutorialIfNeed() {
    // only check tutorial if not all done
    if (!Cache.instance.shouldCheckTutorial(tutorialName, tutorialVersion)) {
      return;
    }

    if (showTutorialIfNeed()) {
      Cache.instance.setTutorialVersion(tutorialName, tutorialVersion);
    }
  }

  void showTutorial(Tutorial Function() builder) {
    // wait a while for initialize
    Future.delayed(Duration(milliseconds: 100), () {
      tutorial = builder()..show();
    });
  }
}

class TutorialStep {
  final GlobalKey key;

  final String? title;

  final String content;

  final void Function()? onTap;

  final ContentAlign contentAlignment;

  final Alignment? skipAlignment;

  final ShapeLightFocus? shape;

  bool isTapped = false;

  TutorialStep({
    required this.key,
    this.title,
    required this.content,
    this.onTap,
    this.contentAlignment = ContentAlign.bottom,
    this.skipAlignment,
    this.shape,
  });
}
