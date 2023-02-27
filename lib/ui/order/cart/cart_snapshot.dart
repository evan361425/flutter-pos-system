import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class CartSnapshot extends StatelessWidget {
  const CartSnapshot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();

    if (cart.isEmpty) {
      return Center(child: HintText(S.orderCartSnapshotEmpty));
    }

    var count = 0;

    final products = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: <Widget>[
        for (final product in cart.products)
          OutlinedText(
            product.name,
            key: Key('cart_snapshot.${count++}'),
            margin: const EdgeInsets.only(right: 4),
            badge: product.count > 9 ? '9+' : product.count.toString(),
            textScaleFactor: 1,
          ),
      ]),
    );

    return Row(children: <Widget>[
      Expanded(child: products),
      const SizedBox(width: 4.0),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          cart.productsPrice.toString(),
          key: const Key('cart_snapshot.price'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ]);
  }
}
