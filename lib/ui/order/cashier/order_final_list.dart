import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/order/order_product.dart';
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
    final selected = Cart.instance.selectedCustomerSettingOptions;

    final priceWidget = ExpansionTile(
      title: Text('總價：$totalPrice 元'),
      children: <Widget>[
        ListTile(
          title: Text('產品總價'),
          trailing: Text(productsPrice.toString()),
        ),
        ListTile(
          title: Text('顧客設定總價'),
          trailing: Text((totalPrice - productsPrice).toString()),
        ),
      ],
    );

    final customerSettingWidget = ExpansionTile(
      title: Text('顧客設定'),
      subtitle: Text('設定 ${selected.length} 項'),
      children: <Widget>[
        for (final option in selected)
          ListTile(
            title: Text(option.name),
            subtitle: option.modeValueName.isNotEmpty
                ? Text(option.modeValueName)
                : null,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -3),
          ),
      ],
    );

    return SingleChildScrollView(
      child: Column(children: [
        priceWidget,
        customerSettingWidget,
        TextDivider(label: '購買產品'),
        for (final product in Cart.instance.products) _ProductTile(product),
      ]),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final OrderProduct product;

  const _ProductTile(this.product);

  @override
  Widget build(BuildContext context) {
    final ingredients = product.getIngredientNames(onlyQuantitied: false);
    final title = Text(product.name);
    final subtitle = MetaBlock.withString(context, <String>[
      '總價：${product.price}',
      '總數：${product.count}',
    ]);

    return ingredients.isEmpty
        ? ListTile(
            title: title,
            subtitle: subtitle,
          )
        : ExpansionTile(
            title: title,
            subtitle: subtitle,
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(children: [
                for (final ingredient in ingredients) OutlinedText(ingredient)
              ]),
              SizedBox(height: 8.0),
            ],
          );
  }
}
