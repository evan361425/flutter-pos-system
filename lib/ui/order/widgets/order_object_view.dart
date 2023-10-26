import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/components/style/head_tail_tile.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class OrderObjectView extends StatelessWidget {
  final OrderObject order;

  const OrderObjectView({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priceWidget = ExpansionTile(
      title: Text(S.orderObjectTotalPrice(order.price.toCurrency())),
      children: <Widget>[
        HeadTailTile(
          head: S.orderObjectProductsPrice,
          tail: order.productsPrice.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectAttributesPrice,
          tail: order.attributesPrice.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectProductsCost,
          tail: order.cost.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectRevenue,
          tail: order.revenue.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectPaid,
          tail: order.paid.toCurrency(),
        ),
      ],
    );

    final attrWidget = order.attributes.isEmpty
        ? const SizedBox.shrink()
        : ExpansionTile(
            key: const Key('order.attributes'),
            title: Text(S.orderObjectAttributeTitle),
            subtitle: Text(
              S.orderObjectAttributeCount(order.attributes.length),
            ),
            children: <Widget>[
              for (final attribute in order.attributes)
                ListTile(
                  title: Text(attribute.name.toString()),
                  subtitle: OrderAttributeValueWidget(
                    attribute.mode,
                    attribute.modeValue,
                  ),
                  trailing: OutlinedText(attribute.optionName.toString()),
                ),
            ],
          );

    return SingleChildScrollView(
      child: Column(children: [
        priceWidget,
        attrWidget,
        TextDivider(label: S.orderObjectProductTitle),
        HintText(S.orderObjectProductsCount(order.productsCount)),
        for (final product in order.products) _ProductTile(product),
      ]),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final OrderProductObject data;

  const _ProductTile(this.data);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(data.productName),
      subtitle: MetaBlock.withString(context, <String>[
        '${S.orderObjectProductPrice}：${data.totalPrice.toCurrency()}',
        '${S.orderObjectProductCost}：${data.totalCost.toCurrency()}',
      ]),
      leading: Menu.instance.getProductByName(data.productName)?.avator ??
          (data.productName != ''
              ? CircleAvatar(
                  child: Text(data.productName.characters.first.toUpperCase()),
                )
              : null),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      childrenPadding: const EdgeInsets.all(8.0),
      children: [
        HeadTailTile(
          head: S.orderObjectProductPrice,
          tail: data.totalPrice.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectProductCost,
          tail: data.totalCost.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectProductCount,
          tail: data.count.toString(),
        ),
        HeadTailTile(
          head: S.orderObjectProductSinglePrice,
          tail: data.singlePrice.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectProductOriginalPrice,
          tail: data.originalPrice.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectProductCatalog,
          tail: data.catalogName,
        ),
        if (data.ingredients.isNotEmpty) const SizedBox(height: 8.0),
        if (data.ingredients.isNotEmpty)
          HeadTailTile(head: S.orderObjectProductIngredient, tail: ''),
        for (final e in data.ingredients)
          HeadTailTile(
            head: e.ingredientName,
            tail: e.quantityName == null ? '（預設）' : e.quantityName!,
          ),
      ],
    );
  }
}
