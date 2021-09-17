import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SlidingUpOpener extends StatefulWidget {
  /// If non-null, this can be used to control the state of the panel.
  final PanelController? controller;

  /// The height of the sliding panel when fully collapsed.
  final double minHeight;

  /// The height of the sliding panel when fully open.
  final double maxHeight;

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

  SlidingUpOpener({
    Key? key,
    required this.panel,
    required this.body,
    required this.collapsed,
    this.controller,
    this.openerKey = 'sliding_up_opener',
    this.minHeight = 100.0,
    this.maxHeight = 500.0,
    this.borderRadius = 16.0,
    this.backdropEnabled = true,
    this.clickToOpen = true,
    this.renderPanelSheet = true,
    this.defaultPanelState = PanelState.CLOSED,
  }) : super(key: key);

  @override
  _SlidingUpOpenerState createState() => _SlidingUpOpenerState();
}

class _SlidingUpOpenerState extends State<SlidingUpOpener> {
  late bool isOpen;

  late PanelController controller;

  Widget buildCollapsed() {
    final theme = Theme.of(context);

    final dragger = Container(
      height: 8.0,
      width: 32.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.shadowColor.withAlpha(176),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );

    final shadow = widget.renderPanelSheet
        ? null
        : const <BoxShadow>[
            BoxShadow(
              blurRadius: 8.0,
              color: Color.fromRGBO(0, 0, 0, 0.5),
            )
          ];
    final margin = widget.renderPanelSheet
        ? const EdgeInsets.symmetric(horizontal: 4.0)
        : const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 0);

    Widget collapsed = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.borderRadius),
        ),
        boxShadow: shadow,
      ),
      child: Column(children: [
        Center(child: dragger),
        Expanded(child: widget.collapsed),
      ]),
    );

    if (widget.clickToOpen) {
      collapsed = IgnorePointer(
        ignoring: isOpen,
        child: GestureDetector(
          key: Key(widget.openerKey),
          // toggle the panel
          onTap: () => controller.open(),
          child: collapsed,
        ),
      );
    }

    return collapsed;
  }

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      margin: const EdgeInsets.only(top: 4.0),
      child: widget.panel,
    );

    return SlidingUpPanel(
      controller: controller,
      minHeight: widget.minHeight,
      maxHeight: widget.maxHeight,
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
        SizedBox(height: widget.minHeight + 80),
      ]),
    );
  }

  @override
  void initState() {
    isOpen = widget.defaultPanelState == PanelState.OPEN;
    controller = widget.controller ?? PanelController();
    super.initState();
  }
}
