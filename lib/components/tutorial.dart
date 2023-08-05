import 'package:flutter/material.dart';
import 'package:possystem/my_app.dart';
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
      routeObserver: MyApp.routeObserver,
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

  final Widget child;

  final Duration bumpDuration;
  final Duration zoomInDuration;
  final Duration zoomOutDuration;
  final Duration contentFadeInDuration;

  const Tutorial({
    Key? key,
    required this.id,
    this.title,
    required this.message,
    this.index,
    this.spotlightBuilder = const SpotlightCircularBuilder(),
    this.padding = const EdgeInsets.all(8),
    this.disable = false,
    required this.child,
    this.bumpDuration = const Duration(milliseconds: 500),
    this.zoomInDuration = const Duration(milliseconds: 600),
    this.zoomOutDuration = const Duration(milliseconds: 600),
    this.contentFadeInDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpotlightAnt(
      actions: const [SpotlightAntAction.prev, SpotlightAntAction.next],
      spotlightBuilder: spotlightBuilder,
      index: index,
      spotlightPadding: padding,
      bumpDuration: bumpDuration,
      zoomInDuration: zoomInDuration,
      zoomOutDuration: zoomOutDuration,
      contentFadeInDuration: contentFadeInDuration,
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
      onDismiss: _onDismiss,
      enable: enabled,
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
      if (shouldShow) {
        SpotlightShow.maybeOf(context)?.start();
        controller.removeListener(handler);
      }
    }

    controller.addListener(handler);
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) => handler());
    hasRegistered = true;
  }
}
