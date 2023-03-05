import 'package:flutter/material.dart';
import 'package:possystem/services/cache.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class TutorialWrapper extends StatelessWidget {
  final Widget child;

  final bool startWhenReady;

  const TutorialWrapper({
    Key? key,
    required this.child,
    this.startWhenReady = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpotlightShow(
      startWhenReady: startWhenReady,
      child: child,
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

  final TutorialInTab? tab;

  final Widget child;

  @visibleForTesting
  final bool fast;

  const Tutorial({
    Key? key,
    required this.id,
    this.title,
    required this.message,
    this.index,
    this.tab,
    this.spotlightBuilder = const SpotlightCircularBuilder(),
    this.padding = const EdgeInsets.all(8),
    this.disable = false,
    required this.child,
    this.fast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final m300 = fast ? Duration.zero : const Duration(milliseconds: 300);
    final m600 = fast ? Duration.zero : const Duration(milliseconds: 600);
    tab?.listenIndexChanging(context);

    return SpotlightAnt(
      actions: const [SpotlightAntAction.prev, SpotlightAntAction.next],
      spotlightBuilder: spotlightBuilder,
      index: index,
      spotlightPadding: padding,
      bumpDuration: m300,
      zoomInDuration: m600,
      zoomOutDuration: m600,
      contentFadeInDuration: m300,
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
