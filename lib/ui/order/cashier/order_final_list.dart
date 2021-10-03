import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/card_tile.dart';
import 'package:possystem/components/style/num_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/repository/cart.dart';

class OrderFinalList extends StatelessWidget {
  final num totalPrice;
  final num productsPrice;

  const OrderFinalList({
    Key? key,
    required this.totalPrice,
    required this.productsPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = <TableRow>[
      TableRow(children: [
        TableCell(child: Text('總價')),
        TableCell(child: NumText(totalPrice, isBold: true)),
      ])
    ];

    if (totalPrice != productsPrice) {
      info.add(TableRow(children: [
        TableCell(child: Text('產品總價')),
        TableCell(child: NumText(productsPrice, isBold: true)),
      ]));
    }

    final selected = Cart.instance.selectedCustomerSettingOptions;
    final customerSettings = selected.isEmpty
        ? const []
        : <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSpacing1),
              child: Column(children: [
                Text('顧客設定'),
                Wrap(children: <Widget>[
                  for (final option in selected) OutlinedText(option.name)
                ]),
              ]),
            ),
            Divider(),
          ];

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(kSpacing1, kSpacing1, kSpacing1, 0),
        child: Table(
          columnWidths: <int, TableColumnWidth>{1: FlexColumnWidth(1)},
          children: info,
        ),
      ),
      Divider(),
      ...customerSettings,
      Expanded(
        child: SingleChildScrollView(
          child: Column(children: [
            for (final product in Cart.instance.products)
              CardTile(
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
