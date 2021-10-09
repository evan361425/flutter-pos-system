import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/fade_in_title_scaffold.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/item_more_action_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/product_ingredient_list.dart';

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
        : ProductIngredientList(product.itemList);

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
          ItemMoreActionButton(
            item: product,
            metadata: MetaBlock.withString(context, <String>[
              '價格：${product.price}',
              '成本：${product.cost}',
            ]),
            onTap: () => _showActions(context, product),
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
