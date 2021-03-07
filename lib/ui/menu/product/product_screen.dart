import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/empty_body.dart';
import 'package:possystem/components/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/ingredient_model.dart';
import 'package:possystem/models/product_model.dart';
import '../catalog/widgets/product_modal.dart';
import 'package:provider/provider.dart';

import 'widgets/ingredient_expansion.dart';
import 'widgets/ingredient_modal.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = context.read<ProductModel>();

    return FadeInTitleScaffold(
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(Icons.arrow_back_ios_sharp),
      ),
      title: product.name,
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => showCupertinoModalPopup(
          context: context,
          builder: _moreActions(product),
        ),
        child: Icon(Icons.more_horiz_sharp),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => IngredientModal(
              ingredient: IngredientModel.empty(product),
            ),
          ));
        },
        tooltip: Local.of(context).t('menu.product.add_integredient'),
        child: Icon(Icons.add),
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

  Widget Function(BuildContext) _moreActions(ProductModel product) {
    return (BuildContext context) {
      return CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (_) => ProductModal(product: product),
              ),
            ),
            child: Text('變更產品'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, 'cancel'),
          child: Text('取消'),
        ),
      );
    };
  }
}
