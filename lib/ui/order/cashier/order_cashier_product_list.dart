import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class OrderCashierProductList extends StatelessWidget {
  final List<OrderSelectedAttributeObject> attributes;
  final List<OrderProductTileData> products;
  final num totalPrice;
  final num productsPrice;
  final num attributePrice;
  final num? productCost;

  /// 淨利，只需考慮總價和成本，不需考慮付額
  final num? income;

  const OrderCashierProductList({
    Key? key,
    required this.attributes,
    required this.products,
    required this.totalPrice,
    required this.productsPrice,
    this.productCost,
    this.income,
  })  : attributePrice = totalPrice - productsPrice,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final priceWidget = ExpansionTile(
      title: Text(S.orderCashierTotalPrice(totalPrice)),
      children: <Widget>[
        ListTile(
          title: Text(S.orderCashierProductTotalPrice),
          trailing: Text(productsPrice.toCurrency()),
        ),
        if (productCost != null)
          ListTile(
            title: Text(S.orderCashierProductTotalCost),
            trailing: Text(productCost!.toCurrency()),
          ),
        if (income != null)
          ListTile(
            title: Text(S.orderCashierIncome),
            trailing: Text(income!.toCurrency()),
          ),
        ListTile(
          title: Text(S.orderCashierAttributeTotalPrice),
          trailing: Text(attributePrice.toCurrency()),
        ),
      ],
    );

    final attrWidget = attributes.isEmpty
        ? const SizedBox.shrink()
        : ExpansionTile(
            key: const Key('order_cashier_product_list.attributes'),
            title: Text(S.orderCashierAttributeInfoTitle),
            subtitle:
                Text(S.orderCashierAttributeTotalCount(attributes.length)),
            children: <Widget>[
              for (final attribute in attributes)
                ListTile(
                  title: Row(children: [
                    Text(attribute.name.toString()),
                    OutlinedText(attribute.optionName.toString()),
                  ]),
                  subtitle: OrderAttributeValueWidget(
                    attribute.mode,
                    attribute.modeValue,
                  ),
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -3),
                ),
            ],
          );

    final totalCount = products.fold<int>(
      0,
      (value, data) => value + data.totalCount,
    );

    return SingleChildScrollView(
      child: Column(children: [
        priceWidget,
        attrWidget,
        TextDivider(label: S.orderCashierProductInfoTitle),
        HintText(S.orderCashierProductMetaCount(totalCount)),
        for (final product in products) _ProductTile(product),
      ]),
    );
  }
}

class OrderProductTileData {
  final Iterable<String> ingredientNames;
  final String productName;
  final num totalPrice;
  final num? totalCost;
  final int totalCount;

  OrderProductTileData({
    required this.ingredientNames,
    required this.productName,
    required this.totalPrice,
    this.totalCost,
    required this.totalCount,
  });
}

class _ProductTile extends StatelessWidget {
  final OrderProductTileData data;

  const _ProductTile(this.data);

  @override
  Widget build(BuildContext context) {
    final title = Text(data.productName);
    final subtitle = MetaBlock.withString(context, <String>[
      S.orderCashierProductMetaPrice(data.totalPrice),
      S.orderCashierProductMetaCount(data.totalCount),
      if (data.totalCost != null)
        S.orderCashierProductMetaCost(data.totalCost!),
    ]);

    final widget = data.ingredientNames.isEmpty
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
                for (final ingredient in data.ingredientNames)
                  OutlinedText(ingredient)
              ]),
              const SizedBox(height: 8.0),
            ],
          );

    return widget;
  }
}
