import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/order/payment_intent.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/ui/order/checkout/checkout_payment_panel.dart';

/// Owns checkout tender [ValueNotifier]s and builds [PaymentIntent]s.
class CheckoutTenderState {
  late final ValueNotifier<num> price;
  late final ValueNotifier<num> paid;
  late final ValueNotifier<PaymentMethod> method;
  late final ValueNotifier<num> cashAmount;
  late final ValueNotifier<num> cardAmount;

  CheckoutTenderState() {
    price = ValueNotifier(Cart.instance.price);
    paid = ValueNotifier(price.value);
    method = ValueNotifier(PaymentMethod.cash);
    final half = (price.value / 2).toCurrencyNum();
    cashAmount = ValueNotifier(price.value - half);
    cardAmount = ValueNotifier(half);
    price.addListener(_syncPaidToPrice);
  }

  void _syncPaidToPrice() {
    if (method.value != PaymentMethod.mixed) {
      paid.value = price.value;
    }
  }

  List<PaymentIntent> intents() {
    return buildCheckoutPayments(
      method: method.value,
      paid: paid.value,
      cashAmount: cashAmount.value,
      cardAmount: cardAmount.value,
    );
  }

  void dispose() {
    price.removeListener(_syncPaidToPrice);
    price.dispose();
    paid.dispose();
    method.dispose();
    cashAmount.dispose();
    cardAmount.dispose();
  }
}
