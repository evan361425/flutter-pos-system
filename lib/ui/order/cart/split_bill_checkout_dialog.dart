import 'package:flutter/material.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/order/payment_intent.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/checkout/checkout_payment_panel.dart';
import 'package:possystem/ui/order/checkout/checkout_totals_banner.dart';

/// Checkout dialog for a split-bill subtotal (cash / card / mixed).
Future<List<PaymentIntent>?> showSplitBillCheckoutDialog({
  required BuildContext context,
  required num subtotal,
  required num totalTax,
  required num grandTotal,
}) {
  return showDialog<List<PaymentIntent>>(
    context: context,
    builder: (context) => _SplitBillCheckoutDialog(
      subtotal: subtotal,
      totalTax: totalTax,
      grandTotal: grandTotal,
    ),
  );
}

class _SplitBillCheckoutDialog extends StatefulWidget {
  final num subtotal;
  final num totalTax;
  final num grandTotal;

  const _SplitBillCheckoutDialog({
    required this.subtotal,
    required this.totalTax,
    required this.grandTotal,
  });

  @override
  State<_SplitBillCheckoutDialog> createState() =>
      _SplitBillCheckoutDialogState();
}

class _SplitBillCheckoutDialogState extends State<_SplitBillCheckoutDialog> {
  late final ValueNotifier<num> _price;
  late final ValueNotifier<num> _paid;
  late final ValueNotifier<PaymentMethod> _method;
  late final ValueNotifier<num> _cashAmount;
  late final ValueNotifier<num> _cardAmount;

  @override
  void initState() {
    super.initState();
    _price = ValueNotifier(widget.grandTotal);
    _paid = ValueNotifier(widget.grandTotal);
    _method = ValueNotifier(PaymentMethod.cash);
    final half = (widget.grandTotal / 2).toCurrencyNum();
    _cashAmount = ValueNotifier(widget.grandTotal - half);
    _cardAmount = ValueNotifier(half);
  }

  @override
  void dispose() {
    _price.dispose();
    _paid.dispose();
    _method.dispose();
    _cashAmount.dispose();
    _cardAmount.dispose();
    super.dispose();
  }

  void _confirm() {
    final payments = buildCheckoutPayments(
      method: _method.value,
      paid: _paid.value,
      cashAmount: _cashAmount.value,
      cardAmount: _cardAmount.value,
    );
    Navigator.of(context).pop(payments);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.orderSplitBillCheckoutTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            children: [
              CheckoutTotalsBanner(
                subtotal: widget.subtotal,
                totalTax: widget.totalTax,
                grandTotal: widget.grandTotal,
              ),
              CheckoutPaymentPanel(
                price: _price,
                paid: _paid,
                method: _method,
                cashAmount: _cashAmount,
                cardAmount: _cardAmount,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          key: const Key('split_bill.checkout.confirm'),
          onPressed: _confirm,
          child: Text(S.orderSplitBillPaySelected),
        ),
      ],
    );
  }
}
