import 'package:flutter/material.dart';
import 'package:possystem/components/scrollable_draggable_sheet.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/ui/order/cart/cart_snapshot.dart';

class DraggableSheetView extends StatefulWidget {
  final Widget row1;
  final Widget row2;
  final Widget row3_1;
  final Widget Function(
    ScrollController scroll,
    ValueNotifier<bool> scrollable,
  ) row3_2Builder;
  final Widget row3_3;
  final Widget row4;
  final ChangeNotifier? resetNotifier;

  const DraggableSheetView({
    super.key,
    required this.row1,
    required this.row2,
    required this.row3_1,
    required this.row3_2Builder,
    required this.row3_3,
    required this.row4,
    this.resetNotifier,
  });

  @override
  State<DraggableSheetView> createState() => _DraggableSheetViewState();
}

class _DraggableSheetViewState extends State<DraggableSheetView> {
  static const double itemHeight = 72.0;
  static const double buttonHeight = 48.0;
  static const double snapshotHeight = 52.0;
  static const double stateSelectorHeight = 52.0;

  late final ScrollableDraggableController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: widget.row1,
            ),
            Expanded(
              key: const Key('order.bg'),
              child: GestureDetector(
                onTap: () => controller.reset(),
                child: widget.row2,
              ),
            ),
          ],
        ),
      ),
      Positioned.fill(
        child: ScrollableDraggableSheet(
          controller: controller,
          indicator: const DraggableIndicator(key: Key('order.ds')),
          onSnapIndexChanged: (index, scroll) {
            if (index == 1 && Cart.instance.selectedIndex != -1) {
              // if only one item can show, the selected item should be it.
              scroll.jumpTo(Cart.instance.selectedIndex * itemHeight);
            }
          },
          builder: (controller, scroll, scrollable) => [
            FixedHeightClipper(
              controller: controller,
              height: snapshotHeight,
              baselineSize: -2 * controller.snapSizes[0],
              valueScalar: -1,
              child: CartSnapshot(controller: controller),
            ),
            FixedHeightClipper(
              controller: controller,
              height: buttonHeight,
              exposeFraction: 0.5,
              baselineSize: controller.snapSizes[1],
              child: widget.row3_1,
            ),
            widget.row3_2Builder(scroll, scrollable),
            FixedHeightClipper(
              controller: controller,
              height: buttonHeight,
              exposeFraction: 0.5,
              baselineSize: controller.snapSizes[1],
              child: widget.row3_3,
            ),
            FixedHeightClipper(
              controller: controller,
              height: stateSelectorHeight * 2,
              baselineSize: controller.snapSizes[0],
              child: widget.row4,
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();

    const base = stateSelectorHeight * 2 + itemHeight;
    controller = ScrollableDraggableController(const [
      snapshotHeight,
      base,
      1.0,
    ]);

    Cart.instance.addListener(_showStateSelectorIfStartOrder);
    widget.resetNotifier?.addListener(_reset);
  }

  @override
  void dispose() {
    Cart.instance.removeListener(_showStateSelectorIfStartOrder);
    widget.resetNotifier?.removeListener(_reset);
    super.dispose();
  }

  void _showStateSelectorIfStartOrder() {
    // first order
    if (controller.isAttached && Cart.instance.products.length == 1 && controller.snapIndex.value == 0) {
      controller.jumpTo(controller.snapSizes[1]);
    }
  }

  void _reset() {
    if (controller.isAttached) {
      controller.reset();
    }
  }
}
