import 'package:flutter/material.dart';
import 'package:possystem/components/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/product_model.dart';

class ProductMetadata extends StatelessWidget {
  const ProductMetadata({
    Key key,
    @required this.product,
  }) : super(key: key);

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Tooltip(
          message: '售價',
          child: IconText(
            text: product.price.toString(),
            iconName: 'loyalty_sharp',
          ),
        ),
        MetaBlock(),
        Tooltip(
          message: '成本',
          child: IconText(
            text: product.cost.toString(),
            iconName: 'attach_money_sharp',
          ),
        ),
      ],
    );
  }
}
