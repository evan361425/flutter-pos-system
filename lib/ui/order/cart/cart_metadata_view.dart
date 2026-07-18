import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/routes/app_route_names.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cart/cart_actions.dart';
import 'package:provider/provider.dart';

class CartMetadataView extends StatelessWidget {
  const CartMetadataView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();
    final canSplit = cart.tableId != null && !cart.isEmpty;

    return Row(
      children: <Widget>[
        const SizedBox(width: 16.0),
        const CartActions(),
        if (canSplit) ...[
          const SizedBox(width: 8.0),
          OutlinedButton.icon(
            key: const Key('cart.action.split_bill'),
            onPressed: () => context.pushNamed(AppRouteNames.orderSplitBill),
            icon: const Icon(Icons.call_split_outlined, size: 18),
            label: Text(S.orderActionSplitBill),
          ),
        ],
        const SizedBox(width: 16.0),
        Expanded(
          key: const Key('cart.metadata'),
          child: MetaBlock.withString(context, <String>[
            S.orderCartMetaTotalCount(cart.productCount),
            S.orderCartMetaTotalPrice(cart.productsPrice.toCurrency()),
          ])!,
        ),
        const SizedBox(width: 16.0),
      ],
    );
  }
}
