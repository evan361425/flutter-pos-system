import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'cart_actions.dart';
import 'cart_product_list.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selector = Row(children: <Widget>[
      Expanded(
        child: OutlinedButton(
          key: const Key('cart.select_all'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Cart.instance.toggleAll(true),
          child: Text(S.orderCartSelectAll),
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
    ]);

    final actions = Row(children: <Widget>[
      const CartActions(),
      const SizedBox(width: kSpacing3),
      Expanded(child: _CartMetadata()),
    ]);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: selector,
          ),
          // no padding here to show full width of tile
          const Expanded(child: CartProductList()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: actions,
          ),
        ],
      ),
    );
  }
}

class _CartMetadata extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();

    return Container(
      key: const Key('cart.metadata'),
      child: MetaBlock.withString(context, <String>[
        S.orderMetaTotalCount(cart.totalCount),
        S.orderMetaTotalPrice(cart.productsPrice),
      ]),
    );
  }
}
