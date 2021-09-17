import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class CartSnapshot extends StatefulWidget {
  CartSnapshot({Key? key}) : super(key: key);

  @override
  _CartSnapshotState createState() => _CartSnapshotState();
}

class _CartSnapshotState extends State<CartSnapshot> {
  @override
  Widget build(BuildContext context) {
    // listen change quantity, delete product
    final cart = context.watch<Cart>();

    if (cart.isEmpty) {
      return Center(child: HintText('尚未點餐'));
    }

    final products = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: <Widget>[
        for (final product in cart.products)
          OutlinedText(
            product.product.name,
            badge: product.count > 9 ? '9+' : product.count.toString(),
          ),
      ]),
    );

    return Row(children: <Widget>[
      Expanded(child: products),
      const SizedBox(width: 16.0),
      OutlinedText(cart.totalPrice.toString()),
    ]);
  }

  void _listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // listen count changing
    OrderProduct.addListener(
      _listener,
      OrderProductListenerTypes.count,
    );
  }

  @override
  void dispose() {
    OrderProduct.removeListener(
      _listener,
      OrderProductListenerTypes.count,
    );
    super.dispose();
  }
}
