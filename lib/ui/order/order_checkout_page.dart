import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scrollable_draggable_sheet.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/checkout/checkout_cashier_calculator.dart';
import 'package:possystem/ui/order/checkout/checkout_cashier_snapshot.dart';
import 'package:possystem/ui/order/checkout/stashed_order_list_view.dart';
import 'package:possystem/ui/order/widgets/order_object_view.dart';

import 'checkout/checkout_attribute_view.dart';

class OrderCheckoutPage extends StatefulWidget {
  const OrderCheckoutPage({super.key});

  @override
  State<OrderCheckoutPage> createState() => _OrderCheckoutPageState();
}

class _OrderCheckoutPageState extends State<OrderCheckoutPage> {
  late final ValueNotifier<num> paid;

  late final ValueNotifier<num> price;

  final ValueNotifier<int> viewIndex = ValueNotifier(0);

  final bool hasAttr = OrderAttributes.instance.hasNotEmptyItems;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Breakpoint.find(width: constraint.maxWidth) <= Breakpoint.medium
          ? _Mobile(
              paid: paid,
              price: price,
              viewIndex: viewIndex,
              hasAttr: hasAttr,
            )
          : _Desktop(
              paid: paid,
              price: price,
              viewIndex: viewIndex,
              hasAttr: hasAttr,
            );
    });
  }

  @override
  void initState() {
    super.initState();

    price = ValueNotifier(Cart.instance.price);
    paid = ValueNotifier(price.value);
    price.addListener(() => paid.value = price.value);
  }

  @override
  void dispose() {
    price.dispose();
    paid.dispose();
    super.dispose();
  }
}

class _Mobile extends StatefulWidget {
  final ValueNotifier<num> paid;

  final ValueNotifier<num> price;

  final ValueNotifier<int> viewIndex;

  final bool hasAttr;

  const _Mobile({
    required this.paid,
    required this.price,
    required this.viewIndex,
    required this.hasAttr,
  });

  @override
  State<_Mobile> createState() => _MobileState();
}

class _MobileState extends State<_Mobile> with SingleTickerProviderStateMixin {
  static const double snapshotHeight = 64.0;
  static const double calculatorHeight = 408.0;

  late final TabController _controller;

  ScrollableDraggableController? draggableController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: Cart.instance.isEmpty
            ? null
            : <Widget>[
                const _StashButton(),
                _ConfirmButton(price: widget.price, paid: widget.paid),
              ],
        bottom: TabBar(
          controller: _controller,
          tabs: [
            if (widget.hasAttr) Tab(key: const Key('order.details.attr'), text: S.orderCheckoutAttributeTab),
            Tab(key: const Key('order.details.order'), text: S.orderCheckoutCashierTab),
            Tab(key: const Key('order.details.stashed'), text: S.orderCheckoutStashTab),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (Cart.instance.isEmpty) {
      return TabBarView(controller: _controller, children: [
        if (widget.hasAttr) CheckoutAttributeView(price: widget.price),
        Center(child: HintText(S.orderCheckoutEmptyCart)),
        const StashedOrderListView(),
      ]);
    }

    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          onTap: () => draggableController?.reset(),
          child: TabBarView(controller: _controller, children: [
            if (widget.hasAttr) CheckoutAttributeView(price: widget.price),
            ValueListenableBuilder(
              valueListenable: widget.paid,
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
                child: CheckoutCashierSnapshot(price: widget.price, paid: widget.paid),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  child: SizedBox(
                    height: calculatorHeight,
                    child: CheckoutCashierCalculator(
                      onSubmit: () => _ConfirmButton.confirm(
                        context,
                        price: widget.price.value,
                        paid: widget.paid.value,
                      ),
                      price: widget.price,
                      paid: widget.paid,
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

  @override
  void initState() {
    super.initState();

    _controller = TabController(
      initialIndex: widget.viewIndex.value,
      length: widget.hasAttr ? 3 : 2,
      vsync: this,
    );
    _controller.addListener(() {
      widget.viewIndex.value = _controller.index;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Desktop extends StatelessWidget {
  final ValueNotifier<num> paid;

  final ValueNotifier<num> price;

  final ValueNotifier<int> viewIndex;

  final bool hasAttr;

  const _Desktop({
    required this.paid,
    required this.price,
    required this.viewIndex,
    required this.hasAttr,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: Cart.instance.isEmpty
            ? null
            : [
                const _StashButton(),
                _ConfirmButton(price: price, paid: paid),
              ],
      ),
      body: ListenableBuilder(
        listenable: viewIndex,
        builder: (context, _) {
          return Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(children: [
                    _buildSwitcher(),
                    _buildBody(context),
                  ]),
                ),
              ),
              if (!Cart.instance.isEmpty)
                CheckoutCashierCalculator(
                  onSubmit: () => _ConfirmButton.confirm(
                    context,
                    price: price.value,
                    paid: paid.value,
                  ),
                  price: price,
                  paid: paid,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (viewIndex.value) {
      case 0:
        return CheckoutAttributeView(price: price);
      case 1:
        if (Cart.instance.isEmpty) {
          return Center(child: HintText(S.orderCheckoutEmptyCart));
        }
        return ValueListenableBuilder(
          valueListenable: paid,
          builder: (context, value, child) => OrderObjectView(
            order: Cart.instance.toObject(paid: value),
          ),
        );
      default:
        return const StashedOrderListView();
    }
  }

  Widget _buildSwitcher() {
    return SegmentedButton<int>(
      selected: {viewIndex.value},
      onSelectionChanged: (value) => viewIndex.value = value.first,
      segments: [
        ButtonSegment(value: 0, label: Text(S.orderCheckoutAttributeTab)),
        ButtonSegment(value: 1, label: Text(S.orderCheckoutCashierTab)),
        ButtonSegment(value: 2, label: Text(S.orderCheckoutStashTab)),
      ],
    );
  }
}

class _StashButton extends StatelessWidget {
  const _StashButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('order.details.stash'),
      onPressed: () async {
        final ok = await Cart.instance.stash();
        if (context.mounted && ok && context.canPop()) {
          context.pop(CheckoutStatus.stash);
        }
      },
      tooltip: S.orderCheckoutActionStash,
      icon: const Icon(Icons.archive_outlined),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final ValueNotifier<num> paid;

  final ValueNotifier<num> price;

  const _ConfirmButton({required this.price, required this.paid});

  static void confirm(BuildContext context, {required num price, required num paid}) async {
    final status = await Cart.instance.checkout(price, paid);

    // send success message
    if (context.mounted) {
      if (status == CheckoutStatus.paidNotEnough) {
        showSnackBar(context, S.orderCheckoutSnackbarPaidFailed);
      } else if (context.canPop()) {
        context.pop(status);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('order.details.confirm'),
      onPressed: () => confirm(context, price: price.value, paid: paid.value),
      tooltip: S.orderCheckoutActionConfirm,
      icon: const Icon(Icons.next_plan_outlined),
    );
  }
}
