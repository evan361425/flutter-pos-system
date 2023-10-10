import 'package:flutter/material.dart';
import 'package:possystem/components/style/sliding_up_opener.dart';
import 'package:possystem/models/repository/cart.dart';

import 'order_cashier_calculator.dart';
import '../widgets/order_object_view.dart';
import 'order_cashier_snapshot.dart';

class OrderCashierView extends StatefulWidget {
  const OrderCashierView({Key? key}) : super(key: key);

  @override
  State<OrderCashierView> createState() => _OrderCashierViewState();
}

class _OrderCashierViewState extends State<OrderCashierView> {
  final opener = GlobalKey<SlidingUpOpenerState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = Cart.instance.price;

    final collapsed = OrderCashierSnapshot(price: price);

    final panel = Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
      ),
      child: OrderCashierCalculator(
        onSubmit: () => opener.currentState?.close(),
        totalPrice: price,
      ),
    );

    final body = OrderObjectView(order: Cart.instance.toObject());

    return SlidingUpOpener(
      key: opener,
      // 4 rows * 64 + 24 (insets) + 64 (collapse)
      maxHeight: 408,
      minHeight: 84,
      heightOffset: 12.0,
      renderPanelSheet: false,
      body: body,
      panel: panel,
      collapsed: collapsed,
    );
  }
}
