import 'package:flutter/material.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class CartMetadata extends StatefulWidget {
  const CartMetadata({
    Key? key,
  }) : super(key: key);

  @override
  _CartMetadataState createState() => _CartMetadataState();
}

class _CartMetadataState extends State<CartMetadata> {
  @override
  Widget build(BuildContext context) {
    // listen change quantity, delete product
    final cart = context.watch<CartModel>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(tt('order.total_count', {'count': cart.totalCount})),
          SizedBox(width: 4.0),
          Text(tt('order.total_price', {'price': cart.totalPrice})),
        ],
      ),
    );
  }

  void _listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // listen count changing
    OrderProductModel.addListener(
      _listener,
      OrderProductListenerTypes.count,
    );
  }

  @override
  void dispose() {
    OrderProductModel.removeListener(
      _listener,
      OrderProductListenerTypes.count,
    );
    super.dispose();
  }
}
