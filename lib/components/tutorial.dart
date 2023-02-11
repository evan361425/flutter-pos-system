import 'dart:async';

import 'package:flutter/material.dart';
import 'package:possystem/services/cache.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class TutorialWrapper extends StatefulWidget {
  final Iterable<GlobalKey<TutorialChild>> tutorials;

  final Widget child;

  /// wait time every doWhile
  final int milliseconds;

  /// doWhile count maximum
  final int iterMaximum;

  const TutorialWrapper({
    Key? key,
    required this.tutorials,
    required this.child,
    this.milliseconds = 50,
    this.iterMaximum = 100,
  }) : super(key: key);

  @override
  State<TutorialWrapper> createState() => _TutorialWrapperState();
}

class _TutorialWrapperState extends State<TutorialWrapper> {
  List<GlobalKey<SpotlightAntState>>? ants;

  final ant = Tutorial.buildAnt();

  @override
  Widget build(BuildContext context) {
    return ants?.isNotEmpty == true
        ? Tutorial(
            ant: ant,
            ants: ants,
            id: '',
            message: '',
            disable: true,
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

    for (final target in widget.tutorials) {
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
        ants = widget.tutorials.expand((e) => e.currentState!.ants).toList();
      });
    }
  }
}

class Tutorial extends StatelessWidget {
  final GlobalKey<SpotlightAntState> ant;

  final List<GlobalKey<SpotlightAntState>>? ants;

  final String id;

  final String? title;

  final String message;

  final TutorialShape shape;

  final EdgeInsets padding;

  /// force disabling tutorial
  final bool disable;

  final bool startNow;

  final Widget child;

  @visibleForTesting
  final bool fast;

  const Tutorial({
    Key? key,
    required this.ant,
    this.ants,
    required this.id,
    this.title,
    required this.message,
    this.shape = TutorialShape.circle,
    this.padding = const EdgeInsets.all(8),
    this.disable = false,
    this.startNow = true,
    required this.child,
    this.fast = false,
  }) : super(key: key);

  static GlobalKey<SpotlightAntState> buildAnt() {
    return GlobalKey<SpotlightAntState>();
  }

  @override
  Widget build(BuildContext context) {
    return SpotlightAnt(
      key: ant,
      ants: ants,
      enable: enabled,
      showAfterInit: startNow,
      actions: const [SpotlightAntAction.prev, SpotlightAntAction.next],
      spotlightBuilder: shape == TutorialShape.circle
          ? const SpotlightCircularBuilder()
          : const SpotlightRectBuilder(),
      spotlightPadding: padding,
      bumpDuration: fast ? Duration.zero : const Duration(milliseconds: 400),
      zoomInDuration: fast ? Duration.zero : const Duration(milliseconds: 600),
      zoomOutDuration: fast ? Duration.zero : const Duration(milliseconds: 600),
      contentFadeInDuration:
          fast ? Duration.zero : const Duration(milliseconds: 300),
      content: SpotlightContent(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 64),
        child: Column(children: [
          if (title != null)
            Text(
              title!,
              style: const TextStyle(fontSize: 24),
            ),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 18)),
        ]),
      ),
      onDismiss: _onDismiss,
      child: child,
    );
  }

  bool get enabled {
    if (disable) {
      return false;
    }

    return !(Cache.instance.get<bool>('tutorial.$id') ?? false);
  }

  void _onDismiss() async {
    await Cache.instance.set<bool>('tutorial.$id', true);
  }
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

  bindAnt(GlobalKey<SpotlightAntState> ant, {startNow = false}) {
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
      void handler() {
        if (!shouldNotShow) {
          ant.currentState?.show();
          controller.removeListener(handler);
        }
      }

      controller.addListener(handler);
      if (startNow) {
        handler();
      }
    });
  }
}

mixin TutorialChild<T extends StatefulWidget> on State<T> {
  late List<GlobalKey<SpotlightAntState>> ants;
}

enum TutorialShape {
  rect,
  circle,
}
