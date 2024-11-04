import 'package:flutter/material.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/helpers/setup_example.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/services/cache.dart';
import 'package:possystem/translator.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class TutorialWrapper extends StatelessWidget {
  final Widget child;

  const TutorialWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SpotlightShow(
      child: child,
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

  final bool traceChild;

  final SpotlightBuilder spotlightBuilder;

  final EdgeInsets padding;

  /// force disabling tutorial
  final bool disable;

  /// if true, the tutorial will only be shown when the widget is 100% visible
  final bool monitorVisibility;

  final Widget child;

  /// action to be executed after the tutorial is dismissed
  final Future<void> Function()? action;

  final bool preferVertical;

  static bool debug = false;

  const Tutorial({
    super.key,
    required this.id,
    this.index,
    this.title,
    required this.message,
    this.below,
    this.traceChild = false,
    this.spotlightBuilder = const SpotlightCircularBuilder(),
    this.padding = const EdgeInsets.all(8),
    this.disable = false,
    this.monitorVisibility = false,
    this.action,
    this.preferVertical = false,
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
      traceChild: traceChild,
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
      contentLayout: preferVertical
          ? const SpotlightContentLayoutConfig(prefer: ContentPreferLayout.vertical)
          : const SpotlightContentLayoutConfig(prefer: ContentPreferLayout.largerRatio),
      content: SpotlightContent(
        fontSize: theme.textTheme.titleMedium!.fontSize,
        child: SizedBox(
          width: 500,
          child: Column(children: [
            if (title != null) Text(title!, style: theme.textTheme.headlineMedium!.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            Linkify.fromString(message),
            if (below != null) below!,
          ]),
        ),
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

class MenuTutorial extends StatelessWidget {
  final GlobalKey<TutorialCheckboxListTileState> checkbox = GlobalKey();

  final Widget child;

  MenuTutorial({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Tutorial(
      id: 'home.menu',
      index: 0,
      title: S.menuTutorialTitle,
      message: S.menuTutorialContent,
      traceChild: true,
      below: TutorialCheckboxListTile(
        key: checkbox,
        title: S.menuTutorialCreateExample,
        value: Menu.instance.isEmpty,
      ),
      spotlightBuilder: const SpotlightRectBuilder(),
      action: () async {
        if (checkbox.currentState?.value == true) {
          await setupExampleMenu();
        }
      },
      child: child,
    );
  }
}

class OrderAttrTutorial extends StatelessWidget {
  final GlobalKey<TutorialCheckboxListTileState> checkbox = GlobalKey();

  final Widget child;

  final void Function()? onDismissed;

  OrderAttrTutorial({super.key, required this.child, this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return Tutorial(
      id: 'home.order_attr',
      index: 1,
      title: S.orderAttributeTutorialTitle,
      message: S.orderAttributeTutorialContent,
      below: TutorialCheckboxListTile(
        key: checkbox,
        title: S.orderAttributeTutorialCreateExample,
        value: OrderAttributes.instance.isEmpty,
      ),
      spotlightBuilder: const SpotlightRectBuilder(),
      action: () async {
        onDismissed?.call();
        if (checkbox.currentState?.value == true) {
          await setupExampleOrderAttrs();
        }
      },
      child: child,
    );
  }
}

class TutorialCheckboxListTile extends StatefulWidget {
  final String title;

  final bool value;

  const TutorialCheckboxListTile({super.key, required this.title, required this.value});

  @override
  State<TutorialCheckboxListTile> createState() => TutorialCheckboxListTileState();
}

class TutorialCheckboxListTileState extends State<TutorialCheckboxListTile> {
  late bool value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => setState(() => value = v!),
        tileColor: Theme.of(context).primaryColor,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }
}
