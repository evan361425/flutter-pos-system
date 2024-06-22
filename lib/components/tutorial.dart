import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/services/cache.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class TutorialWrapper extends StatelessWidget {
  final Widget child;

  final TutorialInTab? tab;

  const TutorialWrapper({
    super.key,
    required this.child,
    this.tab,
  });

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

  /// index of the tutorial
  ///
  /// 0-based index, if not provided, the tutorial will be ordered by
  /// the time of the widget built.
  final int? index;

  final String? title;

  final String message;

  /// widget to be placed below the [message]
  final Widget? below;

  final SpotlightBuilder spotlightBuilder;

  final EdgeInsets padding;

  /// force disabling tutorial
  final bool disable;

  /// if true, the tutorial will only be shown when the widget is 100% visible
  final bool monitorVisibility;

  final Widget child;

  final SpotlightDurationConfig duration;

  /// route to be pushed after the tutorial is dismissed
  ///
  /// if [action] is provided, this will be ignored
  final String? route;

  /// action to be executed after the tutorial is dismissed
  final Future<void> Function()? action;

  final bool _hasAction;

  const Tutorial({
    super.key,
    required this.id,
    this.index,
    this.title,
    required this.message,
    this.below,
    this.spotlightBuilder = const SpotlightCircularBuilder(),
    this.padding = const EdgeInsets.all(8),
    this.disable = false,
    this.monitorVisibility = false,
    this.route,
    this.action,
    required this.child,
    this.duration = const SpotlightDurationConfig(
      bump: Duration(milliseconds: 500),
      zoomIn: Duration(milliseconds: 600),
      zoomOut: Duration(milliseconds: 600),
      contentFadeIn: Duration(milliseconds: 200),
    ),
  }) : _hasAction = route != null || action != null;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    final goSkip = _hasAction ? () => SpotlightAntAction.skip : null;
    return SpotlightAnt(
      enable: enabled,
      index: index,
      duration: duration,
      monitorId: monitorVisibility ? 'tutorial.$id' : null,
      onDismiss: _onDismiss,
      onDismissed: _hasAction
          ? () async {
              await (action?.call() ?? context.pushNamed(route!));

              // try start the next tutorial, if exists
              if (context.mounted) {
                SpotlightShow.maybeOf(context)?.start();
              }
            }
          : null,
      spotlight: SpotlightConfig(
        builder: spotlightBuilder,
        padding: padding,
        onTap: goSkip,
      ),
      backdrop: SpotlightBackdropConfig(onTap: goSkip),
      action: const SpotlightActionConfig(
        enabled: [SpotlightAntAction.prev, SpotlightAntAction.next],
      ),
      content: SpotlightContent(
        child: Column(children: [
          if (title != null)
            // headline medium style
            Text(title!, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, wordSpacing: 0.25)),
          const SizedBox(height: 16),
          Text(message),
          if (below != null) below!,
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
  final TabController? controller;
  final BuildContext? context;
  final int index;

  bool hasRegistered = false;

  TutorialInTab({
    this.controller,
    this.context,
    required this.index,
  }) : assert(controller != null || context != null);

  /// get the tab controller, if not provided, use the default one
  TabController? get cont {
    return controller ?? (context!.mounted ? DefaultTabController.of(context!) : null);
  }

  bool get shouldShow {
    return index == cont?.index && !cont!.indexIsChanging;
  }

  void listenIndexChanging(BuildContext context) {
    if (hasRegistered) {
      return;
    }

    void handler() {
      if (shouldShow && context.mounted) {
        SpotlightShow.maybeOf(context)?.start();
        cont?.removeListener(handler);
      }
    }

    cont?.addListener(handler);
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
      handler();
    });
    hasRegistered = true;
  }
}
