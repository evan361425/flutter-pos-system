/// Supported tender types for a restaurant checkout.
enum PaymentMethod {
  cash,
  card,
  voucher,

  /// UI session marker for multi-tender flows; prefer atomic intents in storage.
  mixed;

  static PaymentMethod fromName(String? name) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == name,
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// A single payment line applied to an order (amount + method).
class PaymentIntent {
  final num amount;
  final PaymentMethod method;

  const PaymentIntent({required this.amount, required this.method});

  Map<String, Object?> toMap() => {'amount': amount, 'method': method.name};

  factory PaymentIntent.fromMap(Map<String, dynamic> data) {
    return PaymentIntent(
      amount: data['amount'] as num? ?? 0,
      method: PaymentMethod.fromName(data['method'] as String?),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentIntent &&
        other.amount == amount &&
        other.method == method;
  }

  @override
  int get hashCode => Object.hash(amount, method);
}
