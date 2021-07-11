import 'package:flutter/material.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/translator.dart';

import 'cart_actions.dart';
import 'cart_metadata.dart';
import 'cart_product_list.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key, this.productsKey}) : super(key: key);

  final Key? productsKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => CartModel.instance.toggleAll(true),
                child: Text(tt('order.cart.select_all')),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: ElevatedButton(
                onPressed: () => CartModel.instance.toggleAll(),
                child: Text(tt('order.cart.toggle_all')),
              ),
            ),
          ],
        ),
        Expanded(child: CartProductList(key: productsKey)),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing3),
              child: CartActions(),
            ),
            Expanded(
              child: CartMetadata(),
            ),
          ],
        ),
      ],
    );
  }
}
