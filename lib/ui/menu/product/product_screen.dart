import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/empty_body.dart';
import 'package:possystem/components/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/menu/product_model.dart';
import 'package:possystem/ui/menu/menu_routes.dart';
import 'package:provider/provider.dart';

import 'widgets/ingredient_expansion.dart';
import 'widgets/ingredient_modal.dart';
import 'widgets/product_actions.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = context.read<ProductModel>();

    return FadeInTitleScaffold(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(KIcons.back),
      ),
      title: product.name,
      trailing: IconButton(
        onPressed: () => showCupertinoModalPopup(
          context: context,
          useRootNavigator: false,
          builder: (BuildContext context) => ProductActions(product: product),
        ),
        icon: Icon(KIcons.more),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => IngredientModal(
              product: product,
            ),
          ));
        },
        tooltip: Local.of(context).t('menu.product.add_integredient'),
        child: Icon(KIcons.add),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final product = context.watch<ProductModel>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _productName(product, context),
              _productMetadata(product, context),
            ],
          ),
        ),
        product.ingredients.isEmpty
            ? EmptyBody('趕緊按右下角的按鈕新增成份吧！')
            : IngredientExpansion(),
      ],
    );
  }

  Widget _productName(ProductModel product, BuildContext context) {
    return Text(
      product.name,
      style: Theme.of(context).textTheme.headline4,
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
