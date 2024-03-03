import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cart/cart_actions.dart';
import 'package:provider/provider.dart';

class CartMetadataView extends StatelessWidget {
  const CartMetadataView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();

    return Row(children: <Widget>[
      const SizedBox(width: 16.0),
      const CartActions(),
      const SizedBox(width: 16.0),
      Expanded(
        key: const Key('cart.metadata'),
        child: MetaBlock.withString(context, <String>[
          S.orderMetaTotalCount(cart.productCount),
          S.orderMetaTotalPrice(cart.productsPrice),
        ])!,
      ),
      const SizedBox(width: 16.0),
    ]);
  }
}
