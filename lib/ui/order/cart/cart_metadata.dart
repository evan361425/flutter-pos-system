import 'package:flutter/material.dart';
import 'package:possystem/models/order/order_product_model.dart';
import 'package:possystem/models/repository/cart_repo.dart';
import 'package:provider/provider.dart';

class CartMetadata extends StatefulWidget {
  const CartMetadata({
    Key key,
  }) : super(key: key);

  @override
  _CartMetadataState createState() => _CartMetadataState();
}

class _CartMetadataState extends State<CartMetadata> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartRepo>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text('總數： ${cart.totalCount}'),
          SizedBox(width: 4.0),
          Text('總價： ${cart.totalPrice}'),
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
    OrderProductModel.addListener(
      _listener,
      OrderProductListenerTypes.count,
    );
  }

  @override
  void dispose() {
    OrderProductModel.removeListener(_listener);
    super.dispose();
  }
}
