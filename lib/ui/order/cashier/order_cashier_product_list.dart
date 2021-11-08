import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

class OrderCashierProductList extends StatelessWidget {
  final List<CustomerSettingOption> customerSettings;
  final List<OrderProductTileData> products;
  final num totalPrice;
  final num productsPrice;
  final num customerPrice;

  const OrderCashierProductList({
    Key? key,
    required this.customerSettings,
    required this.products,
    required this.totalPrice,
    required this.productsPrice,
  })  : customerPrice = totalPrice - productsPrice,
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
        ListTile(
          title: Text(S.orderCashierCustomerTotalPrice),
          trailing: Text(customerPrice.toCurrency()),
        ),
      ],
    );

    final customerSettingWidget = customerSettings.isEmpty
        ? Container()
        : ExpansionTile(
            title: Text(S.orderCashierCustomerInfoTitle),
            subtitle:
                Text(S.orderCashierCustomerTotalCount(customerSettings.length)),
            children: <Widget>[
              for (final option in customerSettings)
                ListTile(
                  title: Text(option.name),
                  subtitle: option.modeValueName.isNotEmpty
                      ? Text(option.modeValueName)
                      : null,
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
        customerSettingWidget,
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
  final int totalCount;

  OrderProductTileData({
    required this.ingredientNames,
    required this.productName,
    required this.totalPrice,
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
    ]);

    return data.ingredientNames.isEmpty
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
  }
}
