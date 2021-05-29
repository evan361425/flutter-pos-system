import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/helper/custom_styles.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/providers/currency_provider.dart';

class OrderModal extends StatelessWidget {
  final OrderObject order;

  const OrderModal({Key key, @required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hour = order.createdAt.hour.toString().padLeft(2, '0');
    final minute = order.createdAt.minute.toString().padLeft(2, '0');
    final second = order.createdAt.second.toString().padLeft(2, '0');
    return SimpleDialog(
      title: Center(child: Text('$hour:$minute:$second')),
      children: [
        _metadata(context),
        for (var product in order.products) _productTile(context, product)
      ],
    );
  }

  Widget _metadata(BuildContext context) {
    return Center(
      child: MetaBlock.withString(context, [
        '售價： ${order.totalPrice}',
        '付款： ${order.paid}',
      ]),
    );
  }

  Widget _productTile(BuildContext context, OrderProductObject product) {
    final ingredients = product.ingredients.values.map((e) {
      final quantity = e.quantityName == null ? '' : '（${e.quantityName}）';
      return '${e.name}$quantity';
    });

    return ListTile(
      title: Text('${product.productName} * ${product.count}'),
      subtitle: MetaBlock.withString(context, ingredients),
      trailing: Text(
        CurrencyProvider.instance
            .numToString(product.singlePrice * product.count),
      ),
    );
  }
}
