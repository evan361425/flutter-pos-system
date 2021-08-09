import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class CartMetadata extends StatefulWidget {
  final bool isVertical;

  const CartMetadata({Key? key, this.isVertical = false}) : super(key: key);

  @override
  _CartMetadataState createState() => _CartMetadataState();
}

class _CartMetadataState extends State<CartMetadata> {
  @override
  Widget build(BuildContext context) {
    // listen change quantity, delete product
    final cart = context.watch<Cart>();

    if (widget.isVertical) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(tt('order.total_count', {'count': cart.totalCount})),
        Text(tt('order.total_price', {'price': cart.totalPrice})),
      ]);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        Text(tt('order.total_count', {'count': cart.totalCount})),
        MetaBlock(),
        Text(tt('order.total_price', {'price': cart.totalPrice})),
      ]),
    );
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
