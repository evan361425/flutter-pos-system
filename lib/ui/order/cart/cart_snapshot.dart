import 'package:flutter/material.dart';
import 'package:possystem/components/scrollable_draggable_sheet.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

class CartSnapshot extends StatelessWidget {
  final ScrollableDraggableController controller;

  const CartSnapshot({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();

    if (cart.isEmpty) {
      return Center(child: HintText(S.orderCartSnapshotEmpty));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(children: <Widget>[
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: cart.products.length,
            itemBuilder: (context, index) {
              final product = cart.products[index];
              return GestureDetector(
                onTap: () {
                  cart.toggleAll(false, except: product);
                  if (controller.isAttached) {
                    controller.jumpTo(controller.snapSizes[1]);
                  }
                },
                child: OutlinedText(
                  product.name,
                  key: Key('cart_snapshot.$index'),
                  margin: const EdgeInsets.only(right: 8),
                  badge: product.count > 9 ? '9+' : product.count.toString(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16.0),
        Text(
          cart.productsPrice.toCurrency(),
          key: const Key('cart_snapshot.price'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }
}
