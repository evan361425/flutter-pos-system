import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/scrollable_draggable_sheet.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/repository/cart.dart';
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Breakpoint.find(width: constraint.maxWidth) <= Breakpoint.medium
          ? _Mobile(
              paid: paid,
              price: price,
              viewIndex: viewIndex,
            )
          : _Desktop(
              paid: paid,
              price: price,
              viewIndex: viewIndex,
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

  const _Mobile({
    required this.paid,
    required this.price,
    required this.viewIndex,
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
            Tab(key: const Key('order.details.attr'), text: S.orderCheckoutAttributeTab),
            Tab(key: const Key('order.details.order'), text: S.orderCheckoutDetailsTab),
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
        CheckoutAttributeView(price: widget.price),
        Center(child: HintText(S.orderCheckoutEmptyCart)),
        const StashedOrderListView(),
      ]);
    }

    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
          onTap: () => draggableController?.reset(),
          child: TabBarView(controller: _controller, children: [
            CheckoutAttributeView(price: widget.price),
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
                      onSubmit: () => _ConfirmButton.confirm(context, paid: widget.paid.value),
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
      length: 3,
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

  const _Desktop({
    required this.paid,
    required this.price,
    required this.viewIndex,
  });

  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (!Cart.instance.isEmpty) {
      child = SizedBox(
        width: 360,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kHorizontalSpacing,
                kTopSpacing,
                kHorizontalSpacing,
                kInternalSpacing,
              ),
              child: SizedBox(
                height: 36,
                child: CheckoutCashierSnapshot(price: price, paid: paid, showChange: false),
              ),
            ),
            Expanded(
              child: CheckoutCashierCalculator(
                onSubmit: () => _ConfirmButton.confirm(context, paid: paid.value),
                price: price,
                paid: paid,
              ),
            ),
          ],
        ),
      );
    }

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
        builder: (context, calculator) {
          return Row(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(children: [
                      _buildSwitcher(),
                      Expanded(child: _buildBody(context)),
                    ]),
                  ),
                ),
              ),
              const VerticalDivider(width: 1),
              if (calculator != null) calculator,
            ],
          );
        },
        child: child,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (viewIndex.value == 0) {
      return CheckoutAttributeView(price: price);
    }

    if (viewIndex.value == 1) {
      if (Cart.instance.isEmpty) {
        return Center(child: HintText(S.orderCheckoutEmptyCart));
      }

      return ValueListenableBuilder(
        valueListenable: paid,
        builder: (context, value, child) => OrderObjectView(
          order: Cart.instance.toObject(paid: value),
        ),
      );
    }

    return const StashedOrderListView();
  }

  Widget _buildSwitcher() {
    return SegmentedButton<int>(
      selected: {viewIndex.value},
      onSelectionChanged: (value) => viewIndex.value = value.first,
      segments: [
        ButtonSegment(value: 0, label: Text(S.orderCheckoutAttributeTab)),
        ButtonSegment(value: 1, label: Text(S.orderCheckoutDetailsTab)),
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

  static void confirm(BuildContext context, {required num paid}) async {
    final future = Cart.instance.checkout(paid: paid, context: context);
    final status = await showSnackbarWhenFutureError(future, 'order_checkout', context: context);

    if (context.mounted && status != null) {
      if (status == CheckoutStatus.paidNotEnough) {
        showSnackBar(S.orderCheckoutSnackbarPaidFailed, context: context);
      } else if (context.canPop()) {
        // send success message
        context.pop(status);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('order.details.confirm'),
      onPressed: () => confirm(context, paid: paid.value),
      tooltip: S.orderCheckoutActionConfirm,
      icon: const Icon(Icons.check_outlined),
    );
  }
}
