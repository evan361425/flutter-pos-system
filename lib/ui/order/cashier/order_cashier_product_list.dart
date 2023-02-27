import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/menu/product.dart';
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

  /// 付額
  final num? paid;

  const OrderCashierProductList({
    Key? key,
    required this.attributes,
    required this.products,
    required this.totalPrice,
    required this.productsPrice,
    this.productCost,
    this.income,
    this.paid,
  })  : attributePrice = totalPrice - productsPrice,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final priceWidget = ExpansionTile(
      title: Text(S.orderCashierTotalPrice(totalPrice)),
      children: <Widget>[
        ListTile(
          title: Text(S.orderCashierProductTotalPriceLabel),
          trailing: Text(productsPrice.toCurrency()),
        ),
        ListTile(
          title: Text(S.orderCashierAttributeTotalPrice),
          trailing: Text(attributePrice.toCurrency()),
        ),
        if (productCost != null)
          ListTile(
            title: Text(S.orderCashierProductTotalCostLabel),
            trailing: Text(productCost!.toCurrency()),
          ),
        if (income != null)
          ListTile(
            title: Text(S.orderCashierIncomeLabel),
            trailing: Text(income!.toCurrency()),
          ),
        if (paid != null)
          ListTile(
            title: Text(S.orderCashierPaidLabel),
            trailing: Text(paid!.toCurrency()),
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
        TextDivider(label: S.orderCashierProductInfoTitle),
        HintText(S.orderCashierProductMetaCount(productCount)),
        for (final product in products) _ProductTile(product),
        // avoid calculator overlapping it
        const SizedBox(height: 36),
      ]),
    );
  }

  int get productCount {
    return products.fold<int>(0, (v, p) => v + p.totalCount);
  }
}

class OrderProductTileData {
  final Iterable<String> ingredientNames;
  final String productName;
  final Product? product;
  final num totalPrice;
  final num? totalCost;
  final int totalCount;

  OrderProductTileData({
    this.product,
    required this.productName,
    required this.ingredientNames,
    required this.totalPrice,
    required this.totalCount,
    this.totalCost,
  });
}

class _ProductTile extends StatelessWidget {
  final OrderProductTileData data;

  const _ProductTile(this.data);

  @override
  Widget build(BuildContext context) {
    final texts = <String>[
      S.orderCashierProductMetaPrice(data.totalPrice),
      S.orderCashierProductMetaCount(data.totalCount),
      if (data.totalCost != null)
        S.orderCashierProductMetaCost(data.totalCost!),
      if (data.product != null)
        S.orderCashierProductMetaCatalog(data.product!.catalog.name),
      if (data.ingredientNames.isNotEmpty) S.orderCashierProductMetaIngredient,
    ];
    return ExpansionTile(
      title: Text(data.productName),
      subtitle: MetaBlock.withString(context, <String>[
        S.orderCashierProductMetaPrice(data.totalPrice),
        S.orderCashierProductMetaCount(data.totalCount),
        if (data.totalCost != null)
          S.orderCashierProductMetaCost(data.totalCost!),
      ]),
      leading: data.product?.avator,
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      childrenPadding: const EdgeInsets.all(8.0),
      children: [
        for (final text in texts)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(text),
          ),
        Wrap(spacing: 4, runSpacing: 4, children: [
          for (final ingredient in data.ingredientNames)
            OutlinedText(ingredient),
        ]),
      ],
    );
  }
}
