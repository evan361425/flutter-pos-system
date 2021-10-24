import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'cart_actions.dart';
import 'cart_product_list.dart';

class CartScreen extends StatelessWidget {
  final Key? productsKey;

  const CartScreen({Key? key, this.productsKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selector = Row(children: <Widget>[
      Expanded(
        child: ElevatedButton(
          key: Key('cart.select_all'),
          onPressed: () => Cart.instance.toggleAll(true),
          child: Text(tt('order.cart.select_all')),
        ),
      ),
      const SizedBox(width: 4.0),
      Expanded(
        child: ElevatedButton(
          key: Key('cart.toggle_all'),
          onPressed: () => Cart.instance.toggleAll(null),
          child: Text(tt('order.cart.toggle_all')),
        ),
      ),
    ]);

    final actions = Row(children: <Widget>[
      CartActions(),
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
          Expanded(child: CartProductList(key: productsKey)),
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
      key: Key('cart.metadata'),
      child: MetaBlock.withString(context, <String>[
        tt('order.total_count', {'count': cart.totalCount}),
        tt('order.total_price', {'price': cart.productsPrice}),
      ]),
    );
  }
}
