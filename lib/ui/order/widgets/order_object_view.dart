import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/components/style/head_tail_tile.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/translator.dart';

class OrderObjectView extends StatelessWidget {
  final OrderObject order;

  const OrderObjectView({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final priceWidget = ExpansionTile(
      title: Text(S.orderObjectViewPriceTotal(order.price.toCurrency())),
      children: <Widget>[
        HeadTailTile(
          head: S.orderObjectViewPriceProducts,
          tail: order.productsPrice.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectViewPriceAttributes,
          tail: order.attributesPrice.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectViewCost,
          tail: order.cost.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectViewProfit,
          tail: order.profit.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectViewPaid,
          tail: order.paid.toCurrency(),
        ),
      ],
    );

    final attrWidget = order.attributes.isEmpty
        ? const SizedBox.shrink()
        : ExpansionTile(
            key: const Key('order.attributes'),
            title: Text(S.orderObjectViewDividerAttribute),
            subtitle: Text(
              S.totalCount(order.attributes.length),
            ),
            children: <Widget>[
              for (final attribute in order.attributes)
                ListTile(
                  title: Text(attribute.name.toString()),
                  subtitle: OrderAttributeValueWidget.build(attribute.mode, attribute.modeValue),
                  trailing: OutlinedText(attribute.optionName.toString()),
                ),
            ],
          );

    final Widget noteWidget;
    if (order.note.isEmpty) {
      noteWidget = const SizedBox.shrink();
    } else {
      noteWidget = Card(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(S.orderObjectViewNote, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: kInternalSpacing),
                Text(order.note),
              ]),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(children: [
        priceWidget,
        attrWidget,
        noteWidget,
        TextDivider(label: S.orderObjectViewDividerProduct),
        HintText(S.totalCount(order.productsCount)),
        for (final product in order.products) _ProductTile(product),
        // padding for ScrollableDraggableSheet on OrderDetailsPage
        const SizedBox(height: 428),
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
        '${S.orderObjectViewProductPrice}：${data.totalPrice.toCurrency()}',
        '${S.orderObjectViewProductCost}：${data.totalCost.toCurrency()}',
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
          head: S.orderObjectViewProductPrice,
          tail: data.totalPrice.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectViewProductCost,
          tail: data.totalCost.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectViewProductCount,
          tail: data.count.toString(),
        ),
        HeadTailTile(
          head: S.orderObjectViewProductSinglePrice,
          tail: data.singlePrice.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectViewProductOriginalPrice,
          tail: data.originalPrice.toCurrency(),
        ),
        HeadTailTile(
          head: S.orderObjectViewProductCatalog,
          tail: data.catalogName,
        ),
        if (data.ingredients.isNotEmpty) const SizedBox(height: 8.0),
        if (data.ingredients.isNotEmpty) HeadTailTile(head: S.orderObjectViewProductIngredient, tail: ''),
        for (final e in data.ingredients)
          HeadTailTile(
            head: e.ingredientName,
            tailWidget: e.quantityName == null ? HintText(S.orderObjectViewProductDefaultQuantity) : null,
            tail: e.quantityName,
          ),
      ],
    );
  }
}
