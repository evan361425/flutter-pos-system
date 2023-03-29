import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SlidingUpOpener extends StatefulWidget {
  /// If non-null, this can be used to control the state of the panel.
  final PanelController? controller;

  /// The height of the sliding panel when fully collapsed.
  final double minHeight;

  /// The height of the sliding panel when fully open.
  final double maxHeight;

  final double heightOffset;

  /// If non-null, shows a darkening shadow over the [body] as
  /// the panel slides open.
  final bool backdropEnabled;

  final bool clickToOpen;

  final bool renderPanelSheet;

  final double borderRadius;

  /// The default state of the panel.
  ///
  /// Either [PanelState.OPEN] or [PanelState.CLOSED].
  ///
  /// This value defaults to [PanelState.CLOSED] which indicates that the
  /// panel is in the closed position and must be opened.
  /// [PanelState.OPEN] indicates that by default the [panel] is open
  /// and must be swiped closed by the user.
  final PanelState defaultPanelState;

  /// Key for collapsed wrapper.
  final String openerKey;

  /// The Widget that slides into view.
  ///
  /// When the panel is collapsed and if [collapsed] is null, then
  /// top portion of this Widget will be displayed; otherwise, [collapsed]
  /// will be displayed overtop of this Widget.
  final Widget panel;

  /// The Widget that lies underneath the sliding panel.
  ///
  /// This Widget automatically sizes itself to fill the screen.
  final Widget body;

  /// The Widget displayed overtop the [panel] when collapsed.
  ///
  /// This fades out as the panel is opened.
  final Widget collapsed;

  final double collapsedHorizontalMargin;

  final bool catchPopScope;

  const SlidingUpOpener({
    Key? key,
    required this.panel,
    required this.body,
    required this.collapsed,
    this.controller,
    this.openerKey = 'sliding_up_opener',
    this.minHeight = 160.0,
    this.maxHeight = 500.0,
    this.borderRadius = 16.0,
    this.heightOffset = 0.0,
    this.backdropEnabled = true,
    this.catchPopScope = true,
    this.clickToOpen = true,
    this.renderPanelSheet = true,
    this.defaultPanelState = PanelState.CLOSED,
    this.collapsedHorizontalMargin = 4.0,
  }) : super(key: key);

  @override
  State<SlidingUpOpener> createState() => SlidingUpOpenerState();
}

class SlidingUpOpenerState extends State<SlidingUpOpener> {
  late bool isOpen;

  late PanelController controller;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      margin: const EdgeInsets.only(top: 4.0),
      child: widget.panel,
    );

    Widget target = SlidingUpPanel(
      controller: controller,
      minHeight: widget.minHeight,
      // 88 for appBar
      maxHeight: min(MediaQuery.of(context).size.height - 88, widget.maxHeight),
      backdropEnabled: widget.backdropEnabled,
      renderPanelSheet: widget.renderPanelSheet,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      color: Colors.transparent,
      onPanelClosed:
          widget.clickToOpen ? () => setState(() => isOpen = false) : null,
      onPanelOpened:
          widget.clickToOpen ? () => setState(() => isOpen = true) : null,
      defaultPanelState: widget.defaultPanelState,
      panel: panel,
      collapsed: buildCollapsed(),
      body: Column(children: [
        Expanded(child: widget.body),
        SizedBox(height: widget.minHeight + widget.heightOffset + 80),
      ]),
    );

    if (widget.catchPopScope) {
      target = WillPopScope(
        onWillPop: () async {
          final isOpen = controller.isPanelOpen;
          if (isOpen) {
            close();
          }

          return !isOpen;
        },
        child: target,
      );
    }

    return target;
  }

  Widget buildCollapsed() {
    final withDragger = _CollapseWithDragger(
      borderRadius: widget.borderRadius,
      collapsedHorizontalMargin: widget.collapsedHorizontalMargin,
      renderPanelSheet: widget.renderPanelSheet,
      child: widget.collapsed,
    );
    if (!widget.clickToOpen) {
      return withDragger;
    }

    return IgnorePointer(
      ignoring: isOpen,
      child: GestureDetector(
        key: Key(widget.openerKey),
        // toggle the panel
        onTap: () => controller.open(),
        child: withDragger,
      ),
    );
  }

  void close() => controller.close();

  @override
  void initState() {
    isOpen = widget.defaultPanelState == PanelState.OPEN;
    controller = widget.controller ?? PanelController();
    super.initState();
  }
}

class _CollapseWithDragger extends StatelessWidget {
  final bool renderPanelSheet;

  final double collapsedHorizontalMargin;

  final double borderRadius;

  final Widget child;

  const _CollapseWithDragger({
    Key? key,
    required this.renderPanelSheet,
    required this.collapsedHorizontalMargin,
    required this.borderRadius,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dragger = Container(
      height: 4.0,
      width: 36.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.highlightColor,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
    );

    final shadow = renderPanelSheet
        ? null
        : const <BoxShadow>[
            BoxShadow(
              blurRadius: 8.0,
              color: Color.fromRGBO(0, 0, 0, 0.5),
            )
          ];
    final margin = renderPanelSheet
        ? const EdgeInsets.symmetric(horizontal: 4.0)
        : EdgeInsets.fromLTRB(
            collapsedHorizontalMargin,
            4.0,
            collapsedHorizontalMargin,
            0,
          );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius),
        ),
        boxShadow: shadow,
      ),
      child: Column(children: [
        Center(child: dragger),
        Expanded(child: child),
        const SizedBox(height: 4.0),
      ]),
    );
  }
}
