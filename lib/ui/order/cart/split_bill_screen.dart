import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/services/cart/split_bill_service.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cart/split_bill_checkout_dialog.dart';
import 'package:possystem/ui/order/cart/split_bill_item_list.dart';

/// Split-by-item screen: move lines between "remaining" and "paying now".
class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  late final OrderObject _original;
  late final List<OrderProductObject> _remaining;
  late final List<OrderProductObject> _selected;

  @override
  void initState() {
    super.initState();
    // Snapshot once — line identity is used by [SplitBillService].
    _original = Cart.instance.toObject();
    _remaining = List.from(_original.products);
    _selected = [];
  }

  num get _selectedSubtotal =>
      _selected.fold<num>(0, (sum, p) => sum + p.totalPrice);

  num get _selectedTax => _selected.fold<num>(0, (sum, p) => sum + p.totalTax);

  num get _selectedGrandTotal => _selectedSubtotal + _selectedTax;

  void _moveToSelected(OrderProductObject item) {
    setState(() {
      _remaining.remove(item);
      _selected.add(item);
    });
  }

  void _moveToRemaining(OrderProductObject item) {
    setState(() {
      _selected.remove(item);
      _remaining.add(item);
    });
  }

  Future<void> _paySelected() async {
    if (_selected.isEmpty) {
      showSnackBar(S.orderSplitBillEmptySelection, context: context);
      return;
    }

    final payments = await showSplitBillCheckoutDialog(
      context: context,
      subtotal: _selectedSubtotal,
      totalTax: _selectedTax,
      grandTotal: _selectedGrandTotal,
    );
    if (payments == null || !mounted) return;

    final ok = await showSnackbarWhenFutureError(
      SplitBillService.instance.processPartialCheckout(
        originalStashedOrder: _original,
        selectedItemsToPay: List.from(_selected),
        payments: payments,
      ),
      'split_bill_checkout',
      context: context,
    );

    if (!mounted) return;

    if (ok != true) {
      showSnackBar(S.orderSplitBillFailed, context: context);
      return;
    }

    _reloadCartWithRemaining();
    if (mounted && context.canPop()) {
      context.pop(true);
    }
  }

  void _reloadCartWithRemaining() {
    if (_remaining.isEmpty) {
      Cart.instance.clear();
      return;
    }

    final remainingOrder = OrderObject(
      products: List.from(_remaining),
      attributes: _original.attributes,
      note: _original.note,
      createdAt: _original.createdAt,
      tableId: _original.tableId,
      pax: _original.pax,
      employeeId: _original.employeeId,
      shiftId: _original.shiftId,
    );
    Cart.instance.restore(remainingOrder);
  }

  @override
  Widget build(BuildContext context) {
    final wide = !(Breakpoint.find(width: MediaQuery.sizeOf(context).width) <=
        .medium);

    final remainingList = SplitBillItemList(
      key: const Key('split_bill.remaining'),
      title: S.orderSplitBillRemaining,
      items: _remaining,
      onItemTap: _moveToSelected,
      emptyIcon: Icons.check_circle_outline,
    );
    final selectedList = SplitBillItemList(
      key: const Key('split_bill.selected'),
      title: S.orderSplitBillSelected,
      items: _selected,
      onItemTap: _moveToRemaining,
      emptyIcon: Icons.touch_app_outlined,
    );

    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        title: Text(S.orderSplitBillTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: wide
                ? Row(
                    children: [
                      Expanded(child: remainingList),
                      const VerticalDivider(width: 1),
                      Expanded(child: selectedList),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(child: remainingList),
                      const Divider(height: 1),
                      Expanded(child: selectedList),
                    ],
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const .fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Text(
                    S.orderSplitBillSubtotal(_selectedGrandTotal.toCurrency()),
                    key: const Key('split_bill.subtotal'),
                    textAlign: .end,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: const Key('split_bill.pay'),
                    onPressed: _selected.isEmpty ? null : _paySelected,
                    icon: const Icon(Icons.payment_outlined),
                    label: Text(S.orderSplitBillPaySelected),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
