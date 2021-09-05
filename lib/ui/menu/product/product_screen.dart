import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title_scaffold.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/icon_text.dart';
import 'package:possystem/components/style/item_editable_info.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/ingredient_expansion_tile.dart';

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = context.watch<Product>();
    // if change ingredient in product_ingredient_search
    context.watch<Stock>();
    // if change quantity in product_quantity_search
    context.watch<Quantities>();

    final navigateNewIngredient = () => Navigator.of(context).pushNamed(
          Routes.menuIngredient,
          arguments: product,
        );

    final body = product.isEmpty
        ? EmptyBody(title: '可以設定產品的成份囉！', onPressed: navigateNewIngredient)
        : Column(children: [
            for (final ingredient in product.itemList)
              IngredientExpansionTile(ingredient: ingredient),
          ]);

    return FadeInTitleScaffold(
      leading: PopButton(),
      title: product.name,
      trailing: PopButton(toHome: true),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateNewIngredient,
        tooltip: tt('menu.integredient.add'),
        child: Icon(KIcons.add),
      ),
      body: Column(
        children: [
          ItemEditableInfo(
            item: product,
            metadata: _ProductMetadata(product),
            onEdit: () => _showActions(context, product),
          ),
          body,
        ],
      ),
    );
  }

  void _showActions(BuildContext context, Product product) async {
    await BottomSheetActions.withDelete(
      context,
      deleteCallback: product.remove,
      deleteValue: _Action.delete,
      popAfterDeleted: true,
      warningContent: Text(tt('delete_confirm', {'name': product.name})),
      actions: <BottomSheetAction<_Action>>[
        BottomSheetAction(
          title: Text(tt('menu.product.edit')),
          leading: Icon(Icons.text_fields_sharp),
          navigateArgument: product,
          navigateRoute: Routes.menuProductModal,
        ),
      ],
    );
  }
}

enum _Action {
  delete,
}

class _ProductMetadata extends StatelessWidget {
  final Product product;

  const _ProductMetadata(this.product);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Tooltip(
          message: tt('menu.product.label.price'),
          child: IconText(
            text: product.price.toString(),
            icon: Icons.loyalty_sharp,
          ),
        ),
        MetaBlock(),
        Tooltip(
          message: tt('menu.product.label.cost'),
          child: IconText(
            text: product.cost.toString(),
            icon: Icons.attach_money_sharp,
          ),
        ),
      ],
    );
  }
}
