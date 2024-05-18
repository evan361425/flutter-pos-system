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

  final String? route;

  const Tutorial({
    super.key,
    required this.id,
    this.title,
    required this.message,
    this.index,
    this.spotlightBuilder = const SpotlightCircularBuilder(),
    this.padding = const EdgeInsets.all(8),
    this.disable = false,
    this.monitorVisibility = false,
    this.route,
    required this.child,
    this.duration = const SpotlightDurationConfig(
      bump: Duration(milliseconds: 500),
      zoomIn: Duration(milliseconds: 600),
      zoomOut: Duration(milliseconds: 600),
      contentFadeIn: Duration(milliseconds: 200),
    ),
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return SpotlightAnt(
      enable: enabled,
      index: index,
      duration: duration,
      monitorId: monitorVisibility ? 'tutorial.$id' : null,
      onDismiss: _onDismiss,
      onDismissed: route != null ? () => context.goNamed(route!) : null,
      spotlight: SpotlightConfig(
        builder: spotlightBuilder,
        padding: padding,
        onTap: route != null ? () async => SpotlightAntAction.skip : null,
      ),
      backdrop: SpotlightBackdropConfig(silent: route != null),
      action: const SpotlightActionConfig(
        enabled: [SpotlightAntAction.prev, SpotlightAntAction.next],
      ),
      content: SpotlightContent(
        child: Column(children: [
          if (title != null)
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
          const SizedBox(height: 16),
          Text(message),
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
