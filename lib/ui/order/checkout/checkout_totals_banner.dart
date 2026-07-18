import 'package:flutter/material.dart';
import 'package:possystem/components/style/head_tail_tile.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/translator.dart';

/// Compact cart money summary: Subtotal → Tax → Grand Total.
class CheckoutTotalsBanner extends StatelessWidget {
  final num subtotal;
  final num totalTax;
  final num grandTotal;

  const CheckoutTotalsBanner({
    super.key,
    required this.subtotal,
    required this.totalTax,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          HeadTailTile(
            head: S.orderCheckoutSubtotal,
            tail: subtotal.toCurrency(),
          ),
          HeadTailTile(
            head: S.orderCheckoutTotalTax,
            tail: totalTax.toCurrency(),
          ),
          HeadTailTile(
            head: S.orderCheckoutGrandTotal,
            tailWidget: Text(
              grandTotal.toCurrency(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
