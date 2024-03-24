import 'package:flutter/material.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';

class CartProductSelector extends StatelessWidget {
  const CartProductSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);
    return Row(children: <Widget>[
      const SizedBox(width: 16.0),
      Expanded(
        child: OutlinedButton(
          key: const Key('cart.select_all'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Cart.instance.toggleAll(true),
          child: Text(local.selectAllButtonLabel),
        ),
      ),
      const SizedBox(width: 4.0),
      Expanded(
        child: OutlinedButton(
          key: const Key('cart.toggle_all'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Cart.instance.toggleAll(null),
          child: Text(S.orderCartToggleSelection),
        ),
      ),
      const SizedBox(width: 16.0),
    ]);
  }
}
