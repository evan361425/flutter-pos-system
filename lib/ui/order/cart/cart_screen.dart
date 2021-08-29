import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';

import 'cart_actions.dart';
import 'cart_metadata.dart';
import 'cart_product_list.dart';

class CartScreen extends StatelessWidget {
  final Key? productsKey;

  const CartScreen({Key? key, this.productsKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                key: Key('order.cart.select_all'),
                onPressed: () => Cart.instance.toggleAll(true),
                child: Text(tt('order.cart.select_all')),
              ),
            ),
            SizedBox(width: 4.0),
            Expanded(
              child: ElevatedButton(
                key: Key('order.cart.toggle_all'),
                onPressed: () => Cart.instance.toggleAll(),
                child: Text(tt('order.cart.toggle_all')),
              ),
            ),
          ]),
        ),
        Expanded(child: CartProductList(key: productsKey)),
        Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(horizontal: kSpacing1),
          child: Row(children: [
            CartActions(),
            const SizedBox(width: kSpacing3),
            Expanded(child: CartMetadata()),
          ]),
        ),
      ],
    );
  }
}
