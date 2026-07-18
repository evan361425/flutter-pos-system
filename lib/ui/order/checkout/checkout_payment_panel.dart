import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/order/payment_intent.dart';
import 'package:possystem/services/cart/checkout_service.dart';
import 'package:possystem/translator.dart';

/// Builds [PaymentIntent]s from the checkout tender UI state.
List<PaymentIntent> buildCheckoutPayments({
  required PaymentMethod method,
  required num paid,
  required num cashAmount,
  required num cardAmount,
}) {
  return switch (method) {
    PaymentMethod.card => [
      PaymentIntent(amount: paid, method: PaymentMethod.card),
    ],
    PaymentMethod.mixed => [
      if (cashAmount > 0)
        PaymentIntent(amount: cashAmount, method: PaymentMethod.cash),
      if (cardAmount > 0)
        PaymentIntent(amount: cardAmount, method: PaymentMethod.card),
    ],
    _ => [PaymentIntent(amount: paid, method: PaymentMethod.cash)],
  };
}

/// Cash / Card / Mixed tender selector for checkout.
class CheckoutPaymentPanel extends StatefulWidget {
  final ValueNotifier<num> price;
  final ValueNotifier<num> paid;
  final ValueNotifier<PaymentMethod> method;
  final ValueNotifier<num> cashAmount;
  final ValueNotifier<num> cardAmount;

  const CheckoutPaymentPanel({
    super.key,
    required this.price,
    required this.paid,
    required this.method,
    required this.cashAmount,
    required this.cardAmount,
  });

  @override
  State<CheckoutPaymentPanel> createState() => _CheckoutPaymentPanelState();
}

class _CheckoutPaymentPanelState extends State<CheckoutPaymentPanel> {
  late final TextEditingController _cashController;
  late final TextEditingController _cardController;

  @override
  void initState() {
    super.initState();
    _cashController = TextEditingController(
      text: widget.cashAmount.value.toCurrency(),
    );
    _cardController = TextEditingController(
      text: widget.cardAmount.value.toCurrency(),
    );
    widget.method.addListener(_onMethodChanged);
    widget.price.addListener(_onPriceChanged);
  }

  @override
  void dispose() {
    widget.method.removeListener(_onMethodChanged);
    widget.price.removeListener(_onPriceChanged);
    _cashController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _onMethodChanged() {
    if (widget.method.value != PaymentMethod.mixed) {
      widget.paid.value = widget.price.value;
    }
    setState(() {});
  }

  void _onPriceChanged() {
    if (widget.method.value == PaymentMethod.mixed) {
      final half = (widget.price.value / 2).toCurrencyNum();
      widget.cashAmount.value = widget.price.value - half;
      widget.cardAmount.value = half;
      _cashController.text = widget.cashAmount.value.toCurrency();
      _cardController.text = widget.cardAmount.value.toCurrency();
    } else {
      widget.paid.value = widget.price.value;
    }
  }

  num get _change {
    return CheckoutCashMath.change(
      payments: buildCheckoutPayments(
        method: widget.method.value,
        paid: widget.paid.value,
        cashAmount: widget.cashAmount.value,
        cardAmount: widget.cardAmount.value,
      ),
      grandTotal: widget.price.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: 64,
            child: SegmentedButton<PaymentMethod>(
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(const Size(64, 64)),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
              segments: [
                ButtonSegment(
                  value: PaymentMethod.cash,
                  label: Text(S.orderCheckoutPaymentCash),
                  icon: const Icon(Icons.payments_outlined, size: 18),
                ),
                ButtonSegment(
                  value: PaymentMethod.card,
                  label: Text(S.orderCheckoutPaymentCard),
                  icon: const Icon(Icons.credit_card, size: 18),
                ),
                ButtonSegment(
                  value: PaymentMethod.mixed,
                  label: Text(S.orderCheckoutPaymentMixed),
                  icon: const Icon(Icons.call_split, size: 18),
                ),
              ],
              selected: {widget.method.value},
              onSelectionChanged: (set) => widget.method.value = set.first,
            ),
          ),
        ),
        if (widget.method.value == PaymentMethod.mixed) ...[
          const SizedBox(height: 8),
          _MixedField(
            key: const Key('checkout.payment.cash'),
            label: S.orderCheckoutPaymentCashAmount,
            controller: _cashController,
            onChanged: (v) => widget.cashAmount.value = v,
          ),
          _MixedField(
            key: const Key('checkout.payment.card'),
            label: S.orderCheckoutPaymentCardAmount,
            controller: _cardController,
            onChanged: (v) => widget.cardAmount.value = v,
          ),
          ListenableBuilder(
            listenable: Listenable.merge([
              widget.cashAmount,
              widget.cardAmount,
              widget.price,
            ]),
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  '${S.orderCheckoutDetailsCalculatorLabelChange}: ${_change.toCurrency()}',
                  key: const Key('checkout.payment.change'),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _MixedField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<num> onChanged;

  const _MixedField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: SizedBox(
        height: 64,
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          onChanged: (raw) {
            onChanged(num.tryParse(raw) ?? 0);
          },
        ),
      ),
    );
  }
}
