import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/icon_text.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/localizations.dart';
import 'package:possystem/models/models.dart';
import 'package:possystem/ui/menu/product/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProductModel product = ModalRoute.of(context).settings.arguments;

    return ChangeNotifierProvider<ProductModel>.value(
      value: product,
      builder: (BuildContext context, _) => FadeInTitleScaffold(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(Icons.arrow_back_ios_sharp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: product.name,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(Icons.more_horiz_sharp),
          onPressed: () => showCupertinoModalPopup(
            context: context,
            builder: _moreActions,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {},
          tooltip: Local.of(context).t('menu.product.add_integredient'),
        ),
        body: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final product = context.watch<ProductModel>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _productName(product, context),
              _productMetadata(product, context),
            ],
          ),
        ),
        IngredientExpansion(ingredients: product.ingredients),
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

  Widget _moreActions(BuildContext context) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text('變更名稱'),
          onPressed: () => Navigator.pop(context, 'cancel'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('取消'),
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context, 'cancel'),
      ),
    );
  }
}
