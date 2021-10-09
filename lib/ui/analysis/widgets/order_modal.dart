import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/providers/currency_provider.dart';
import 'package:possystem/translator.dart';

class OrderModal extends StatelessWidget {
  final OrderObject order;

  const OrderModal({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopButton(),
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
                for (var product in order.products) _ProductTile(product),
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
          tt('analysis.price',
              {'price': CurrencyProvider.n2s(order.totalPrice)}),
          tt('analysis.paid', {'paid': CurrencyProvider.n2s(order.paid!)}),
        ])!,
        Text(createdAt)
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final OrderProductObject product;

  const _ProductTile(this.product);

  @override
  Widget build(BuildContext context) {
    final ingredients = product.ingredients.values.map<String>((e) =>
        e.quantityName == null ? e.name : '${e.name} - ${e.quantityName}');
    final title = Text(product.productName);
    final subtitle = MetaBlock.withString(context, <String>[
      '總價：${product.singlePrice * product.count}',
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
