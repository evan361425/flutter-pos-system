/// Copy from tooltip
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:possystem/components/style/custom_shapes.dart';
import 'package:possystem/constants/constant.dart';

class Tip extends StatefulWidget {
  /// The text to display in the tool tip.
  final String message;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The title to display in the tool tip.
  final String? title;

  final bool disabled;

  final bool preferBelow;

  /// The length of time that a tooltutorail will be shown.
  ///
  /// Defaults to 0 milliseconds (tip are shown immediately).
  final Duration waitDuration;

  final VoidCallback? onClosed;

  const Tip({
    Key? key,
    this.title,
    required this.message,
    this.disabled = false,
    this.preferBelow = true,
    this.waitDuration = Duration.zero,
    this.onClosed,
    required this.child,
  }) : super(key: key);

  @override
  TipState createState() => TipState();
}

class TipState extends State<Tip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  OverlayEntry? _entry;
  Timer? _showTimer;

  @override
  Widget build(BuildContext context) {
    if (widget.disabled) {
      return widget.child;
    }
    assert(Overlay.of(context, debugRequiredFor: widget) != null);
    _showTimer ??= Timer(widget.waitDuration, show);

    return widget.child;
  }

  @override
  void deactivate() {
    if (_entry != null) {
      hide(immediately: true);
    }
    _showTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    GestureBinding.instance!.pointerRouter
        .removeGlobalRoute(_handlePointerEvent);
    if (_entry != null) {
      _removeEntry();
    }
    _controller.dispose();
    super.dispose();
  }

  void hide({bool immediately = false}) {
    if (immediately) {
      _removeEntry();
      return;
    }
    _controller.reverse();
    if (widget.onClosed != null) {
      widget.onClosed!();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      reverseDuration: Duration(milliseconds: 75),
      vsync: this,
    )..addStatusListener(_handleStatusChanged);
    // Listen to global pointer events so that we can hide a top immediately
    // if some other control is clicked on.
    GestureBinding.instance!.pointerRouter.addGlobalRoute(_handlePointerEvent);
  }

  void _handlePointerEvent(PointerEvent event) {
    if (_entry == null) {
      return;
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      hide();
    }
  }

  /// Shows the tip if it is not already visible.
  ///
  /// Returns `false` when the tip was already visible or if the context has
  /// become null.
  bool show() {
    _showTimer?.cancel();
    _showTimer = null;
    if (_entry != null) {
      // Stop trying to hide, if we were.
      _controller.forward();
      return false; // Already visible.
    }
    _createNewEntry();
    _controller.forward();
    return true;
  }

  void _createNewEntry() {
    final overlayState = Overlay.of(context)!;

    final box = context.findRenderObject()! as RenderBox;
    final target = box.localToGlobal(
      box.size.center(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );

    // We create this widget outside of the overlay entry's builder to prevent
    // updated values from happening to leak into the overlay when the overlay
    // rebuilds.
    final Widget overlay = Directionality(
      textDirection: Directionality.of(context),
      child: _TiplOverlay(
        title: widget.title,
        message: widget.message,
        animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.fastOutSlowIn,
        ),
        target: target,
        preferBelow: widget.preferBelow,
      ),
    );
    _entry = OverlayEntry(builder: (BuildContext context) => overlay);
    overlayState.insert(_entry!);
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      hide(immediately: true);
    }
  }

  void _removeEntry() {
    _showTimer?.cancel();
    _showTimer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _TiplOverlay extends StatelessWidget {
  final String? title;
  final String message;
  final Animation<double> animation;
  final Offset target;
  final bool preferBelow;

  const _TiplOverlay({
    Key? key,
    required this.message,
    this.title,
    required this.animation,
    required this.target,
    required this.preferBelow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.8;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.white : Colors.grey[700]!;
    final textColor = isDark ? Colors.black : Colors.white;
    final textStyle = theme.textTheme.bodyText1!.copyWith(color: textColor);
    final decoration = ShapeDecoration(
      color: backgroundColor.withOpacity(0.9),
      shape: TipShapeBorder(arrowArc: 0.1, target: target),
    );

    final closer = Container(
      margin: const EdgeInsets.only(top: kSpacing0),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
        color: theme.buttonColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        '我知道了',
        style: textStyle.copyWith(
          color: theme.buttonTheme.colorScheme!.onSurface,
        ),
      ),
    );

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(title!, style: textStyle.copyWith(fontSize: 22)),
        Text(message),
        closer,
      ],
    );

    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _TipPositionDelegate(
          target: target,
          verticalOffset: 42.0, // 24 + 10 + 4
          preferBelow: preferBelow,
        ),
        child: FadeTransition(
          opacity: animation,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 32.0, maxWidth: maxWidth),
            child: DefaultTextStyle(
              style: textStyle,
              child: Container(
                decoration: decoration,
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(kSpacing0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A delegate for computing the layout of a tip to be displayed above or
/// bellow a target specified in the global coordinate system.
class _TipPositionDelegate extends SingleChildLayoutDelegate {
  /// The offset of the target the tip is positioned near in the global
  /// coordinate system.
  final Offset target;

  /// The amount of vertical distance between the target and the displayed
  /// tip.
  final double verticalOffset;

  /// Whether the tip is displayed below its widget by default.
  ///
  /// If there is insufficient space to display the tip in the preferred
  /// direction, the tip will be displayed in the opposite direction.
  final bool preferBelow;

  /// Creates a delegate for computing the layout of a tip.
  ///
  /// The arguments must not be null.
  _TipPositionDelegate({
    required this.target,
    required this.verticalOffset,
    required this.preferBelow,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return positionDependentBox(
      size: size,
      childSize: childSize,
      target: target,
      verticalOffset: verticalOffset,
      preferBelow: preferBelow,
    );
  }

  @override
  bool shouldRelayout(_TipPositionDelegate oldDelegate) {
    return target != oldDelegate.target ||
        verticalOffset != oldDelegate.verticalOffset ||
        preferBelow != oldDelegate.preferBelow;
  }
}
