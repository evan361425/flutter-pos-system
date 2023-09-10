import 'package:flutter/material.dart';
import 'package:possystem/services/cache.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class TutorialWrapper extends StatelessWidget {
  final Widget child;

  final TutorialInTab? tab;

  const TutorialWrapper({
    Key? key,
    required this.child,
    this.tab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpotlightShow(
      startWhenReady: tab == null, // start if no tab passed
      child: Builder(
        builder: (context) {
          tab?.listenIndexChanging(context);
          return child;
        },
      ),
    );
  }
}

class Tutorial extends StatelessWidget {
  final String id;

  final String? title;

  final int? index;

  final String message;

  final SpotlightBuilder spotlightBuilder;

  final EdgeInsets padding;

  /// force disabling tutorial
  final bool disable;

  final bool monitorVisibility;

  final Widget child;

  final SpotlightDurationConfig duration;

  const Tutorial({
    Key? key,
    required this.id,
    this.title,
    required this.message,
    this.index,
    this.spotlightBuilder = const SpotlightCircularBuilder(),
    this.padding = const EdgeInsets.all(8),
    this.disable = false,
    this.monitorVisibility = false,
    required this.child,
    this.duration = const SpotlightDurationConfig(
      bump: Duration(milliseconds: 500),
      zoomIn: Duration(milliseconds: 600),
      zoomOut: Duration(milliseconds: 600),
      contentFadeIn: Duration(milliseconds: 200),
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpotlightAnt(
      enable: enabled,
      index: index,
      duration: duration,
      monitorId: monitorVisibility ? 'tutorial.$id' : null,
      onDismiss: _onDismiss,
      spotlight: SpotlightConfig(
        builder: spotlightBuilder,
        padding: padding,
      ),
      action: const SpotlightActionConfig(
        enabled: [SpotlightAntAction.prev, SpotlightAntAction.next],
      ),
      content: SpotlightContent(
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

  bool hasRegistered = false;

  TutorialInTab({
    required this.controller,
    required this.index,
  });

  bool get shouldShow {
    return index == controller.index && !controller.indexIsChanging;
  }

  void listenIndexChanging(BuildContext context) {
    if (hasRegistered) {
      return;
    }

    void handler() {
      if (shouldShow && context.mounted) {
        SpotlightShow.maybeOf(context)?.start();
        controller.removeListener(handler);
      }
    }

    controller.addListener(handler);
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) => handler());
    hasRegistered = true;
  }
}
