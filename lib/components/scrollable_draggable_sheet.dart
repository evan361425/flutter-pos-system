import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScrollableDraggableSheet extends StatefulWidget {
  final int initSnapIndex;

  final List<double>? snapSizes;

  final ScrollableDraggableController? controller;

  final EdgeInsets margin;

  final DraggableIndicator indicator;

  final void Function(int index, ScrollController scroll)? onSnapIndexChanged;

  final Iterable<Widget> Function(
    ScrollableDraggableController controller,
    ScrollController scroll,
    ValueNotifier<bool> scrollable,
  ) builder;

  const ScrollableDraggableSheet({
    super.key,
    this.initSnapIndex = 0,
    this.snapSizes,
    this.controller,
    this.onSnapIndexChanged,
    this.margin = const EdgeInsets.symmetric(horizontal: 8),
    this.indicator = const DraggableIndicator(),
    required this.builder,
  }) : assert(snapSizes != null || controller != null);

  @override
  State<ScrollableDraggableSheet> createState() => _ScrollableDraggableSheetState();
}

class _ScrollableDraggableSheetState extends State<ScrollableDraggableSheet> {
  late final ScrollableDraggableController controller;

  late ScrollController scroll;

  final scrollable = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        controller.transferSnapSizes(
          constraints.biggest.height,
          widget.margin.vertical,
        );

        return DraggableScrollableSheet(
          controller: controller,
          initialChildSize: controller.snapSizes[widget.initSnapIndex],
          minChildSize: controller.minSnap,
          maxChildSize: controller.maxSnap,
          expand: true,
          snap: true,
          snapSizes: controller.snapSizes,
          shouldCloseOnMinExtent: true,
          builder: (_, scrollController) {
            scroll = scrollController;
            return content;
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScrollableDraggableController(widget.snapSizes!);
    controller.addListener(() {
      if (!controller.isDrag) {
        controller.updateSnapIndex(controller.size);
      }
    });
    controller.snapIndex.addListener(() {
      if (controller.snapIndex.value < controller.snapSizes.length - 1) {
        scrollable.value = false;
      }
      widget.onSnapIndexChanged?.call(controller.snapIndex.value, scroll);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget get content {
    return GestureDetector(
      onVerticalDragStart: (details) {
        controller.isDrag = true;
      },
      onVerticalDragUpdate: (details) {
        // drag up will get minus `dy` which will increase the sheet's height
        final s = controller.pixelsToSize(controller.pixels - details.delta.dy);
        // same assertion in the jumpTo method
        if (s >= 0 && s < 1) {
          controller.jumpTo(s);
        }
      },
      onVerticalDragEnd: (details) {
        controller.animateToClosestSnap(details.velocity.pixelsPerSecond.dy);
      },
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) {
          // can't disable scrolling here
          if (value == 1.0) {
            scrollable.value = true;
          }
          return PopScope(
            canPop: controller.snapIndex.value == 0,
            onPopInvokedWithResult: (popped, _) {
              if (!popped) {
                controller.reset();
              }
            },
            child: Card(
              shape: value == 1.0
                  ? const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                  : const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                    ),
              clipBehavior: Clip.hardEdge,
              elevation: 2.0,
              margin: value == 1.0 ? const EdgeInsets.all(0) : widget.margin,
              child: child,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.indicator,
            ...widget.builder(controller, scroll, scrollable),
          ],
        ),
      ),
    );
  }
}

class ScrollableDraggableController extends DraggableScrollableController implements ValueListenable<double> {
  ScrollableDraggableController(this.pixelsSnapSizes);

  bool isDrag = false;

  final List<double> pixelsSnapSizes;

  late double availablePixels;
  late List<double> snapSizes;
  ValueNotifier<int> snapIndex = ValueNotifier(0);

  transferSnapSizes(double pixels, double offset) {
    final last = pixelsSnapSizes[pixelsSnapSizes.length - 1];
    availablePixels = last > 1 ? last : last * pixels;
    snapSizes =
        pixelsSnapSizes.map((e) => e > 1.0 ? min((e + DraggableIndicator.height + offset) / pixels, 1.0) : e).toList();
    snapIndex.value = 0;
  }

  double get minSnap => snapSizes[0];
  double get maxSnap => snapSizes[snapSizes.length - 1];

  Future<void> animateToClosestSnap(double velocity) async {
    if (isAttached) {
      final index = getNextSnapIndex(velocity);
      await animateTo(
        snapSizes[index],
        duration: const Duration(milliseconds: 120),
        curve: Curves.bounceOut,
      );
      // only update the value after correctly move to target
      isDrag = false;
      snapIndex.value = index;
    }
  }

  void updateSnapIndex(double size) {
    var i = 0;
    for (var element in snapSizes) {
      if (element == size) {
        snapIndex.value = i;
        return;
      }
      i++;
    }
  }

  int getNextSnapIndex(double velocity) {
    // drag up/down but is in max/min
    if ((velocity < 0 && snapIndex.value == snapSizes.length - 1) || (velocity > 0 && snapIndex.value == 0)) {
      return snapIndex.value;
    }

    // drag quickly
    if (velocity < -300.0 || velocity > 300.0) {
      final snap = snapSizes[snapIndex.value];
      final next = snapIndex.value + (velocity < 0 ? 1 : -1);
      // but not over half
      if ((size - snap) / (snapSizes[next] - snap) < .5) {
        return next;
      }
    }

    // find closest
    final i = snapSizes.indexWhere((e) => e >= size);
    final prev = i == 0 ? double.infinity : (snapSizes[i - 1] - size).abs();
    return prev < (snapSizes[i] - size).abs() ? i - 1 : i;
  }

  @override
  double get value => isAttached ? size : 0;

  @override
  void dispose() {
    snapIndex.dispose();
    super.dispose();
  }
}

class DraggableIndicator extends StatelessWidget {
  static const height = 20.0;

  const DraggableIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 4.0,
        width: 36.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}

class FixedHeightClipper extends StatelessWidget {
  final ScrollableDraggableController controller;

  final double height;

  final double exposeFraction;

  final double valueScalar;

  final double baselineSize;

  final double baseline;

  final Widget child;

  const FixedHeightClipper({
    super.key,
    required this.controller,
    required this.height,
    this.baselineSize = 0,
    this.baseline = 0,
    this.exposeFraction = 1.0,
    this.valueScalar = 1.0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        final h = ((valueScalar * value - baselineSize) * controller.availablePixels - baseline) * exposeFraction;

        return Stack(clipBehavior: Clip.hardEdge, children: [
          SizedBox(height: clampDouble(h, 0, height)),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: child!,
          ),
        ]);
      },
      child: SizedBox(
        height: height,
        child: child,
      ),
    );
  }
}
