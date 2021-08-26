import 'package:flutter/material.dart';
import 'package:possystem/components/tip/tip_tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/ui/order/cart/cart_snapshot.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class OrderBySlidingPanel extends StatefulWidget {
  final Widget row1;
  final Widget row2;
  final Widget row3;
  final Widget row4;

  OrderBySlidingPanel({
    Key? key,
    required this.row1,
    required this.row2,
    required this.row3,
    required this.row4,
  }) : super(key: key);

  @override
  _OrderBySlidingPanelState createState() => _OrderBySlidingPanelState();
}

class _OrderBySlidingPanelState extends State<OrderBySlidingPanel> {
  late PanelController panelController;

  bool isOpen = false;

  @override
  void initState() {
    panelController = PanelController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mediaQuery = MediaQuery.of(context);
    const snapshotHeight = 72.0;
    final panelHeight =
        mediaQuery.size.height - mediaQuery.padding.top - kToolbarHeight - 64.0;

    final dragger = Container(
      height: 8.0,
      width: 32.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.shadowColor.withAlpha(176),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );

    final collapsed = TipTutorial(
      label: 'order.panel',
      title: '新版點餐設計',
      message: '為了讓點選產品可以更方便，\n'
          '我們把點餐後的產品設定至於此面板，點選或滑動以查看。\n'
          '如果需要一次顯示所有訊息的排版，可以至「設定」>「點餐的外觀」設定。',
      child: IgnorePointer(
        ignoring: isOpen,
        child: GestureDetector(
          key: Key('order.sliding_panel.opener'),
          // toggle the panel
          onTap: () => panelController.open(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
            ),
            child: Column(children: [
              Center(child: dragger),
              Expanded(
                child: ChangeNotifierProvider.value(
                  value: Cart.instance,
                  builder: (_, __) => Padding(
                    padding: const EdgeInsets.all(kSpacing0),
                    child: CartSnapshot(),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );

    return SlidingUpPanel(
      controller: panelController,
      minHeight: snapshotHeight,
      maxHeight: panelHeight,
      backdropEnabled: true,
      color: Colors.transparent,
      onPanelClosed: () => setState(() => isOpen = false),
      onPanelOpened: () => setState(() => isOpen = true),
      // drag to show
      panel: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: widget.row3),
          widget.row4,
        ],
      ),
      // bottom snapshot
      collapsed: collapsed,
      // base
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        widget.row1,
        Expanded(child: widget.row2),
      ]),
    );
  }
}
