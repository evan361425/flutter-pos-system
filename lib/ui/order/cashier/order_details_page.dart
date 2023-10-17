import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/sliding_up_opener.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cashier/order_cashier_calculator.dart';
import 'package:possystem/ui/order/cashier/order_cashier_snapshot.dart';
import 'package:possystem/ui/order/cashier/stashed_order_list_view.dart';
import 'package:possystem/ui/order/widgets/order_object_view.dart';

import 'order_setting_view.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({Key? key}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage>
    with SingleTickerProviderStateMixin {
  final opener = GlobalKey<SlidingUpOpenerState>();

  late final ValueNotifier<num> paid;

  late final ValueNotifier<num> price;

  late final TabController _controller;

  late final bool hasAttr;

  late final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final collapsed = OrderCashierSnapshot(price: price, paid: paid);

    final panel = Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
      ),
      child: OrderCashierCalculator(
        onSubmit: () => opener.currentState?.close(),
        price: price,
        paid: paid,
      ),
    );

    final tabBarView = TabBarView(controller: _controller, children: [
      if (hasAttr) OderSettingView(price: price),
      OrderObjectView(order: Cart.instance.toObject()),
      StashedOrderListView(handleCheckout: _handleCheckout),
    ]);

    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: [
          TextButton(
            key: const Key('order.checkout'),
            onPressed: () async {
              _handleCheckout(await Cart.instance.checkout(
                price.value,
                paid.value,
              ));
            },
            child: Text(S.orderCashierCheckout),
          ),
        ],
        // disable shadow after scrolled
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _controller,
          tabs: tabs,
        ),
      ),
      body: SlidingUpOpener(
        key: opener,
        // 4 rows * 64 + 24 (insets) + 64 (collapse)
        maxHeight: 408,
        minHeight: 84,
        heightOffset: 12.0,
        renderPanelSheet: false,
        body: tabBarView,
        panel: panel,
        collapsed: collapsed,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    price = ValueNotifier(Cart.instance.price);
    paid = ValueNotifier(price.value);
    price.addListener(() => paid.value = price.value);

    hasAttr = OrderAttributes.instance.hasNotEmptyItems;

    _controller = TabController(
      initialIndex: 0,
      length: hasAttr ? 3 : 2,
      vsync: this,
    );

    tabs = [
      if (hasAttr)
        Tab(key: const Key('order.set_attr'), text: S.orderSetAttributeTitle),
      Tab(key: const Key('order.cashier'), text: S.orderCashierTitle),
      const Tab(key: Key('order.stashed'), text: '暫存訂單'),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    price.dispose();
    paid.dispose();
    super.dispose();
  }

  void _handleCheckout(CheckoutStatus status) {
    // send success message
    if (context.mounted) {
      if (status == CheckoutStatus.paidNotEnough) {
        showSnackBar(context, S.orderCashierPaidFailed);
      } else if (context.canPop()) {
        context.pop(status);
      }
    }
  }
}
