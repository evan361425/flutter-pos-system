import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/cart.dart';

class OrderFinalList extends StatelessWidget {
  const OrderFinalList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final price = Cart.instance.totalPrice;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(kSpacing1),
        child: Column(children: [
          Text(
            price.toString(),
            style: Theme.of(context).textTheme.headline5,
          ),
          HintText('總價'),
        ]),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Column(children: [
            for (final product in Cart.instance.products)
              ListTile(
                title: Text(product.product.name),
                trailing: Text(product.count.toString()),
                subtitle: MetaBlock.withString(
                  context,
                  product.quantitiedIngredientNames,
                  textOverflow: TextOverflow.clip,
                ),
              )
          ]),
        ),
      ),
    ]);
  }
}
