import 'package:flutter/material.dart';
import 'package:possystem/components/linkify.dart';
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

  /// action to be executed after the tutorial is dismissed
  final Future<void> Function()? action;

  static bool debug = false;

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
    this.action,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    final theme = Theme.of(context);
    return SpotlightAnt(
      enable: enabled,
      index: index,
      duration: debug ? SpotlightDurationConfig.zero : const SpotlightDurationConfig(),
      monitorId: monitorVisibility ? 'tutorial.$id' : null,
      onDismiss: _onDismiss,
      onDismissed: action,
      spotlight: SpotlightConfig(
        builder: spotlightBuilder,
        padding: padding,
      ),
      backdrop: const SpotlightBackdropConfig(),
      action: const SpotlightActionConfig(
        enabled: [SpotlightAntAction.prev, SpotlightAntAction.next],
      ),
      content: SpotlightContent(
        fontSize: theme.textTheme.titleMedium!.fontSize,
        child: Column(children: [
          if (title != null) Text(title!, style: theme.textTheme.headlineMedium!.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          Linkify.fromString(message),
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
