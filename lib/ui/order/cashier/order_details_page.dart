import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/scrollable_draggable_sheet.dart';
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
  static const double snapshotHeight = 64.0;
  static const double calculatorHeight = 408.0;

  late final ValueNotifier<num> paid;

  late final ValueNotifier<num> price;

  late final TabController _controller;
  ScrollableDraggableController? draggableController;

  late final bool hasAttr;

  late final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: Cart.instance.isEmpty
            ? const <Widget>[]
            : [
                TextButton(
                  key: const Key('order.details.stash'),
                  style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(
                      theme.textTheme.bodyMedium!.color,
                    ),
                  ),
                  onPressed: _stash,
                  child: const Text('暫存'),
                ),
                TextButton(
                  key: const Key('order.details.confirm'),
                  onPressed: _checkout,
                  child: Text(S.orderDetailsConfirm),
                ),
              ],
        // disable shadow after scrolled
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _controller,
          tabs: tabs,
        ),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    if (Cart.instance.isEmpty) {
      return TabBarView(controller: _controller, children: [
        if (hasAttr) OderSettingView(price: price),
        const Center(child: HintText('請先進行點單。')),
        const StashedOrderListView(),
      ]);
    }

    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          onTap: () => draggableController?.reset(),
          child: TabBarView(controller: _controller, children: [
            if (hasAttr) OderSettingView(price: price),
            ValueListenableBuilder(
              key: const Key('evan'),
              valueListenable: paid,
              builder: (context, value, child) => OrderObjectView(
                order: Cart.instance.toObject(paid: value),
              ),
            ),
            const StashedOrderListView(),
          ]),
        ),
      ),
      Positioned.fill(
        child: ScrollableDraggableSheet(
          indicator: const DraggableIndicator(key: Key('order.details.ds')),
          snapSizes: const [snapshotHeight, calculatorHeight],
          builder: (controller, scroll, _) {
            draggableController = controller;
            return [
              FixedHeightClipper(
                controller: controller,
                height: snapshotHeight,
                baseline: -2 * snapshotHeight,
                valueScalar: -1,
                child: OrderCashierSnapshot(price: price, paid: paid),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  child: SizedBox(
                    height: calculatorHeight,
                    child: OrderCashierCalculator(
                      onSubmit: _checkout,
                      price: price,
                      paid: paid,
                    ),
                  ),
                ),
              )
            ];
          },
        ),
      ),
    ]);
  }

  Future<void> _stash() async {
    final ok = await Cart.instance.stash();
    if (context.mounted && ok && context.canPop()) {
      context.pop(CheckoutStatus.stash);
    }
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
        Tab(
            key: const Key('order.details.attr'),
            text: S.orderSetAttributeTitle),
      Tab(key: const Key('order.details.order'), text: S.orderCashierTitle),
      const Tab(key: Key('order.details.stashed'), text: '暫存訂單'),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    price.dispose();
    paid.dispose();
    super.dispose();
  }

  void _checkout() async {
    final status = await Cart.instance.checkout(price.value, paid.value);

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
