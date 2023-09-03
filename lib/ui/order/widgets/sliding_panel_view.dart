import 'package:flutter/material.dart';
import 'package:possystem/components/style/sliding_up_opener.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cart/cart_snapshot.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class SlidingPanelView extends StatefulWidget {
  final Widget row1;
  final Widget row2;
  final Widget row3;
  final Widget row4;

  const SlidingPanelView({
    Key? key,
    required this.row1,
    required this.row2,
    required this.row3,
    required this.row4,
  }) : super(key: key);

  @override
  State<SlidingPanelView> createState() => SlidingPanelViewState();
}

class SlidingPanelViewState extends State<SlidingPanelView> {
  final opener = GlobalKey<SlidingUpOpenerState>();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    const snapshotHeight = 72.0;
    final panelHeight =
        mediaQuery.size.height - mediaQuery.padding.top - kToolbarHeight - 64.0;

    final collapsed = Tutorial(
      id: 'order.sliding_collapsed',
      padding: const EdgeInsets.fromLTRB(-4, 24, -4, 0),
      title: S.orderCartSnapshotTutorialTitle,
      message: S.orderCartSnapshotTutorialMessage,
      spotlightBuilder: const SpotlightRectBuilder(borderRadius: 16),
      child: ChangeNotifierProvider.value(
        value: Cart.instance,
        builder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: kSpacing0),
          child: CartSnapshot(key: Key('cart.collapsed')),
        ),
      ),
    );

    return SlidingUpOpener(
      key: opener,
      minHeight: snapshotHeight,
      maxHeight: panelHeight,
      collapsed: collapsed,
      panel: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(child: widget.row3), widget.row4],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ColoredBox(
          color: Theme.of(context).colorScheme.background,
          child: widget.row1,
        ),
        Expanded(child: widget.row2),
      ]),
    );
  }

  void reset() {
    setState(() {
      opener.currentState?.close();
    });
  }
}
