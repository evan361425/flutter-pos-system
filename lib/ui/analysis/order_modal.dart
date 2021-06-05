import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/providers/currency_provider.dart';

class OrderModal extends StatelessWidget {
  final OrderObject order;

  const OrderModal({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(KIcons.back)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(kSpacing2),
            child: _metadata(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                for (var product in order.products)
                  _productTile(context, product)
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metadata(BuildContext context) {
    // YYYY-MM-DD HH:mm:ss
    final createdAt = order.createdAt.toString().substring(0, 19);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MetaBlock.withString(context, [
          '售價：${CurrencyProvider.instance.numToString(order.totalPrice)}',
          '付款：${CurrencyProvider.instance.numToString(order.paid!)}',
        ])!,
        Text(createdAt)
      ],
    );
  }

  Widget _productTile(BuildContext context, OrderProductObject product) {
    final ingredients = product.ingredients.values.map((e) {
      final quantity = e.quantityName == null ? '' : '（${e.quantityName}）';
      return '${e.name}$quantity';
    });
    final price = product.singlePrice * product.count;

    return CardTile(
      title: Text('${product.productName} * ${product.count}'),
      subtitle: MetaBlock.withString(context, ingredients),
      trailing: Text(CurrencyProvider.instance.numToString(price)),
    );
  }
}
