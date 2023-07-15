import 'package:flutter/material.dart';
import 'package:possystem/components/style/sliding_up_opener.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';

import 'order_cashier_calculator.dart';
import 'order_cashier_product_list.dart';
import 'order_cashier_snapshot.dart';

class OrderCashierModal extends StatefulWidget {
  const OrderCashierModal({Key? key}) : super(key: key);

  @override
  State<OrderCashierModal> createState() => _OrderCashierModalState();
}

class _OrderCashierModalState extends State<OrderCashierModal> {
  final opener = GlobalKey<SlidingUpOpenerState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPrice = Cart.instance.totalPrice;

    final collapsed = OrderCashierSnapshot(totalPrice: totalPrice);

    final panel = Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
      ),
      child: OrderCashierCalculator(
        onSubmit: () => opener.currentState?.close(),
        totalPrice: totalPrice,
      ),
    );

    final body = OrderCashierProductList(
      attributes: Cart.instance.selectedAttributeOptions
          .map((e) => OrderSelectedAttributeObject.fromModel(e))
          .toList(),
      products: Cart.instance.products
          .map((e) => OrderProductTileData(
                product: e.product,
                productName: e.name,
                ingredientNames: e.getIngredientNames(onlyQuantified: false),
                totalPrice: e.price,
                totalCount: e.count,
              ))
          .toList(),
      totalPrice: totalPrice,
      productsPrice: Cart.instance.productsPrice,
      productCost: Cart.instance.productsCost,
    );

    return SlidingUpOpener(
      key: opener,
      // 4 rows * 64 + 24 (insets) + 64 (collapse)
      maxHeight: 408,
      minHeight: 84,
      heightOffset: 12.0,
      renderPanelSheet: false,
      body: body,
      panel: panel,
      collapsed: collapsed,
    );
  }
}
