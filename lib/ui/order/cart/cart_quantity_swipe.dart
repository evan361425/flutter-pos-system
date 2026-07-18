import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/models/repository/cart.dart';

/// Horizontal swipe gestures for cart line quantity changes.
///
/// Uses [onHorizontalDrag*] only so the vertical [ListView] scroll still wins
/// in Flutter's gesture arena. Thresholds:
/// - slight right → +1
/// - slight left → -1
/// - full left → remove line
class CartQuantitySwipe extends StatefulWidget {
  const CartQuantitySwipe({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  static const double nudgeThreshold = 40;
  static const double dismissThreshold = 120;
  static const double maxDrag = 96;

  @override
  State<CartQuantitySwipe> createState() => _CartQuantitySwipeState();
}

class _CartQuantitySwipeState extends State<CartQuantitySwipe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _snapAnimation;
  double _dx = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _controller.addListener(() {
      final anim = _snapAnimation;
      if (anim == null) return;
      setState(() => _dx = anim.value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isRight = _dx > 0;
    final isDismiss = _dx <= -CartQuantitySwipe.dismissThreshold;
    final bg = isRight
        ? scheme.primaryContainer
        : isDismiss
        ? scheme.errorContainer
        : scheme.tertiaryContainer;
    final fg = isRight
        ? scheme.onPrimaryContainer
        : isDismiss
        ? scheme.onErrorContainer
        : scheme.onTertiaryContainer;
    final icon = isRight
        ? Icons.add
        : isDismiss
        ? Icons.delete_outline
        : Icons.remove;

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onHorizontalDragCancel: _snapBack,
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: bg,
              child: Align(
                alignment: isRight
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(icon, color: fg),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
              _dx.clamp(
                -CartQuantitySwipe.maxDrag,
                CartQuantitySwipe.maxDrag,
              ),
              0,
            ),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.stop();
    setState(() {
      _dx = (_dx + details.delta.dx).clamp(
        -CartQuantitySwipe.maxDrag * 1.4,
        CartQuantitySwipe.maxDrag,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final dx = _dx;
    if (dx >= CartQuantitySwipe.nudgeThreshold) {
      _apply(1);
    } else if (dx <= -CartQuantitySwipe.dismissThreshold) {
      _applyRemove();
      return;
    } else if (dx <= -CartQuantitySwipe.nudgeThreshold) {
      _apply(-1);
    }
    _snapBack();
  }

  void _apply(int delta) {
    HapticFeedback.lightImpact();
    Cart.instance.updateQuantity(widget.index, delta);
  }

  void _applyRemove() {
    HapticFeedback.mediumImpact();
    Cart.instance.removeAt(widget.index);
  }

  void _snapBack() {
    _snapAnimation = Tween<double>(begin: _dx, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller
      ..reset()
      ..forward();
  }
}
