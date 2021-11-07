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
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = context.watch<Product>();
    // if change ingredient in product_ingredient_search
    context.watch<Stock>();
    // if change quantity in product_quantity_search
    context.watch<Quantities>();

    navigateNewIngredient() => Navigator.of(context).pushNamed(
          Routes.menuIngredient,
          arguments: product,
        );

    final body = product.isEmpty
        ? EmptyBody(
            title: S.menuProductEmptyBody, onPressed: navigateNewIngredient)
        : ProductIngredientList(product.itemList);

    return FadeInTitleScaffold(
      leading: const PopButton(),
      title: product.name,
      trailing: const PopButton(toHome: true),
      floatingActionButton: FloatingActionButton(
        key: const Key('product.add'),
        onPressed: navigateNewIngredient,
        tooltip: S.menuIngredientCreate,
        child: const Icon(KIcons.add),
      ),
      body: Column(
        children: [
          ItemMoreActionButton(
            item: product,
            metadata: MetaBlock.withString(context, <String>[
              S.menuProductMetaPrice(product.price),
              S.menuProductMetaCost(product.cost),
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
      deleteValue: 0,
      popAfterDeleted: true,
      warningContent: Text(S.dialogDeletionContent(product.name, '')),
      actions: <BottomSheetAction<int>>[
        BottomSheetAction(
          title: Text(S.menuProductUpdate),
          leading: const Icon(Icons.text_fields_sharp),
          navigateArgument: product,
          navigateRoute: Routes.menuProductModal,
        ),
      ],
    );
  }
}
