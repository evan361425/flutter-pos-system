import 'package:possystem/models/order/payment_intent.dart';

/// Aggregated Z-report metrics for one cash-register shift.
class ShiftReport {
  const ShiftReport({
    required this.shiftId,
    required this.startingCash,
    required this.actualEndingCash,
    required this.orderCount,
    required this.totalSales,
    required this.cashSales,
    required this.cardSales,
    required this.voucherSales,
  });

  final String shiftId;
  final num startingCash;
  final num? actualEndingCash;
  final int orderCount;
  final num totalSales;
  final num cashSales;
  final num cardSales;
  final num voucherSales;

  /// Float + cash tenders that should remain in the drawer.
  num get expectedCash => startingCash + cashSales;

  /// Positive = overage (excédent), negative = shortage (manque).
  num? get variance {
    final actual = actualEndingCash;
    if (actual == null) return null;
    return actual - expectedCash;
  }

  num salesFor(PaymentMethod method) => switch (method) {
    PaymentMethod.cash => cashSales,
    PaymentMethod.card => cardSales,
    PaymentMethod.voucher => voucherSales,
    PaymentMethod.mixed => cashSales + cardSales + voucherSales,
  };
}
