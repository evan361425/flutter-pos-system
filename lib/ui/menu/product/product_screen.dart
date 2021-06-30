import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title_scaffold.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:provider/provider.dart';

import 'widgets/ingredient_expansion.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductModel>();

    return FadeInTitleScaffold(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(KIcons.back),
      ),
      title: product.name,
      trailing: IconButton(
        onPressed: () => showCircularBottomSheet(
          context,
          actions: _actions(context, product),
          useRootNavigator: false,
        ),
        icon: Icon(KIcons.more),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(
          Routes.menuIngredient,
          arguments: product,
        ),
        tooltip: Translator.t('menu.product.add_integredient'),
        child: Icon(KIcons.add),
      ),
      body: _body(context, product),
    );
  }

  List<Widget> _actions(BuildContext context, ProductModel product) {
    return [
      ListTile(
        title: Text('變更產品'),
        leading: Icon(Icons.text_fields_sharp),
        onTap: () => Navigator.of(context).pushReplacementNamed(
          Routes.menuProductModal,
          arguments: product,
        ),
      ),
    ];
  }

  Widget _body(BuildContext context, ProductModel product) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kSpacing3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _productName(product, context),
              _productMetadata(product, context),
            ],
          ),
        ),
        product.isEmpty ? EmptyBody('趕緊按右下角的按鈕新增成份吧！') : IngredientExpansion(),
      ],
    );
  }

  Widget _productMetadata(ProductModel product, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Tooltip(
          message: '售價',
          child: IconText(
            text: product.price.toString(),
            icon: Icons.loyalty_sharp,
          ),
        ),
        MetaBlock(),
        Tooltip(
          message: '成本',
          child: IconText(
            text: product.cost.toString(),
            icon: Icons.attach_money_sharp,
          ),
        ),
      ],
    );
  }

  Widget _productName(ProductModel product, BuildContext context) {
    return Text(
      product.name,
      style: Theme.of(context).textTheme.headline4,
    );
  }
}
