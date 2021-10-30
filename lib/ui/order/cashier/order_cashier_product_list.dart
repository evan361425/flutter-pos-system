import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/providers/currency_provider.dart';

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
      title: Text('總價：${CurrencyProvider.n2s(totalPrice)} 元'),
      children: <Widget>[
        ListTile(
          title: Text('產品總價'),
          trailing: Text(CurrencyProvider.n2s(productsPrice)),
        ),
        ListTile(
          title: Text('顧客設定總價'),
          trailing: Text(CurrencyProvider.n2s(customerPrice)),
        ),
      ],
    );

    final customerSettingWidget = ExpansionTile(
      title: Text('顧客設定'),
      subtitle: Text('設定 ${customerSettings.length} 項'),
      children: <Widget>[
        for (final option in customerSettings)
          ListTile(
            title: Text(option.name),
            subtitle: option.modeValueName.isNotEmpty
                ? Text(option.modeValueName)
                : null,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -3),
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
        TextDivider(label: '購買產品'),
        HintText('總數：$totalCount'),
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
      '總價：${data.totalPrice}',
      '總數：${data.totalCount}',
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
              SizedBox(height: 8.0),
            ],
          );
  }
}
