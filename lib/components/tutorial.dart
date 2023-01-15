import 'dart:async';

import 'package:flutter/material.dart';
import 'package:possystem/services/cache.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialWrapper extends StatefulWidget {
  final Iterable<GlobalKey<TutorialChild>> targets;

  final Widget child;

  /// wait time every doWhile
  final int milliseconds;

  /// doWhile count maximum
  final int iterMaximum;

  const TutorialWrapper({
    Key? key,
    required this.targets,
    required this.child,
    this.milliseconds = 50,
    this.iterMaximum = 100,
  }) : super(key: key);

  @override
  State<TutorialWrapper> createState() => _TutorialWrapperState();
}

class _TutorialWrapperState extends State<TutorialWrapper> {
  Iterable<GlobalKey<State<Tutorial>>>? tutorials;

  @override
  Widget build(BuildContext context) {
    return tutorials?.isNotEmpty == true
        ? Tutorial(
            id: '',
            message: '',
            targets: tutorials,
            child: widget.child,
          )
        : widget.child;
  }

  @override
  void initState() {
    super.initState();

    _prepareTargets();
  }

  void _prepareTargets() async {
    int counter = 0;

    for (final target in widget.targets) {
      await Future.doWhile(() {
        if (counter++ > widget.iterMaximum) {
          return false;
        }
        return Future.delayed(
          Duration(milliseconds: widget.milliseconds),
          () => target.currentState == null,
        );
      });
    }

    if (counter < widget.iterMaximum) {
      setState(() {
        tutorials = widget.targets.expand((e) => e.currentState!.tutorials);
      });
    }
  }
}

class Tutorial extends StatefulWidget {
  static const GlobalKey<State<Tutorial>>? self = null;

  /// Identity for each tutorial
  final String id;

  final String? title;

  final String message;

  /// StatefulWidget's key for targeting
  final Iterable<GlobalKey<State<Tutorial>>?>? targets;

  final TutorialShape shape;

  final TutorialAlign align;

  /// focus target's padding
  final double paddingSize;

  final TutorialInTab? tab;

  /// force disabling tutorial
  final bool disable;

  final Widget child;

  @visibleForTesting
  final Duration animationDuration;

  const Tutorial({
    Key? key,
    required this.id,
    this.title,
    required this.message,
    this.targets,
    this.shape = TutorialShape.circle,
    this.align = TutorialAlign.bottom,
    this.paddingSize = 8,
    this.tab,
    this.disable = false,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  State<Tutorial> createState() => TutorialState();

  ShapeLightFocus get realShape {
    switch (shape) {
      case TutorialShape.circle:
        return ShapeLightFocus.Circle;
      case TutorialShape.rect:
        return ShapeLightFocus.RRect;
    }
  }

  ContentAlign get alignment {
    switch (align) {
      case TutorialAlign.top:
        return ContentAlign.top;
      case TutorialAlign.bottom:
        return ContentAlign.bottom;
    }
  }
}

class TutorialState extends State<Tutorial> {
  final key = GlobalKey<State<_TutorialTemp>>();

  @override
  Widget build(BuildContext context) {
    return widget.targets == null
        ? widget.child
        : _TutorialTemp(key: key, child: widget.child);
  }

  @override
  void initState() {
    super.initState();

    if (widget.targets == null) {
      return;
    }

    if (widget.tab == null) {
      _scheduleFrameCallback();
    } else {
      widget.tab!.shouldNotShow
          ? widget.tab!.controller.addListener(_handleTabChanged)
          : _scheduleFrameCallback();
    }
  }

  void _handleTabChanged() {
    if (widget.tab!.shouldNotShow || !mounted) {
      return;
    }

    // unregister first, avoid non-stop event handler
    widget.tab?.controller.removeListener(_handleTabChanged);

    _showTutorial();
  }

  void _scheduleFrameCallback() {
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
      _showTutorial();
    });
  }

  void _showTutorial() async {
    final targets = <TargetFocus>[];
    final textTheme = Theme.of(context).textTheme;

    for (final tutorial in widget.targets!) {
      Tutorial? target;
      GlobalKey<State<StatefulWidget>>? targetKey;
      if (tutorial == Tutorial.self) {
        target = widget;
        targetKey = key;
      } else if (true == tutorial!.currentState?.mounted) {
        target = tutorial.currentState!.widget;
        targetKey = tutorial;
      }

      // 1. not manually disable it
      // 2. not mounted, user should try add another main tutorial
      // 3. second time facing this tutorial
      if (target?.disable != false ||
          !mounted ||
          (Cache.instance.get<bool>('tutorial.${target!.id}') ?? false)) {
        continue;
      }

      targets.add(TargetFocus(
        identify: target.id,
        keyTarget: targetKey,
        enableOverlayTab: true,
        shape: target.realShape,
        paddingFocus: target.paddingSize,
        focusAnimationDuration: target.animationDuration,
        contents: <TargetContent>[
          TargetContent(
            align: target.alignment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (target.title != null)
                  Text(
                    target.title!,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                Text(
                  target.message,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ));
    }

    if (targets.isNotEmpty) {
      TutorialCoachMark(
        targets: targets,
        onClickOverlay: _onTutorialTap,
        unFocusAnimationDuration: widget.animationDuration,
        focusAnimationDuration: widget.animationDuration,
        onClickTarget: _onTutorialTap,
        hideSkip: true,
      ).show(context: context);
    }
  }

  Future<void> _onTutorialTap(TargetFocus target) async {
    await Cache.instance.set<bool>('tutorial.${target.identify}', true);
  }
}

class _TutorialTemp extends StatefulWidget {
  final Widget child;

  const _TutorialTemp({Key? key, required this.child}) : super(key: key);

  @override
  State<_TutorialTemp> createState() => _TutorialTempState();
}

class _TutorialTempState extends State<_TutorialTemp> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

mixin TutorialChild<T extends StatefulWidget> on State<T> {
  late List<GlobalKey<State<Tutorial>>> tutorials;
}

class TutorialInTab {
  final TabController controller;
  final int index;

  const TutorialInTab({
    required this.controller,
    required this.index,
  });

  bool get shouldNotShow {
    return controller.indexIsChanging || index != controller.index;
  }
}

enum TutorialShape {
  rect,
  circle,
}

enum TutorialAlign {
  top,
  bottom,
}
