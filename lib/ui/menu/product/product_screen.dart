import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slivers/sliver_image_app_bar.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/item_more_action_button.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/ingredient_expantion_card.dart';

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

    final metadata = SliverToBoxAdapter(
      child: ItemMoreActionButton(
        item: MetaBlock.withString(context, <String>[
          S.menuProductMetaPrice(product.price),
          S.menuProductMetaCost(product.cost),
        ])!,
        onTap: () => _showActions(context, product),
      ),
    );

    final ingredients = product.itemList;

    final aboveData = product.isEmpty
        ? SliverToBoxAdapter(
            child: EmptyBody(
                title: S.menuProductEmptyBody,
                onPressed: navigateNewIngredient),
          )
        : SliverToBoxAdapter(
            child: Center(child: HintText(S.totalCount(ingredients.length))),
          );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        key: const Key('product.add'),
        onPressed: navigateNewIngredient,
        tooltip: S.menuIngredientCreate,
        child: const Icon(KIcons.add),
      ),
      body: CustomScrollView(slivers: [
        SliverImageAppBar(title: product.name, image: product.image),
        metadata,
        aboveData,
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, int index) => IngredientExpantionCard(ingredients[index]),
            childCount: ingredients.length,
          ),
        ),
      ]),
    );
  }

  void _showActions(BuildContext context, Product product) async {
    final result = await BottomSheetActions.withDelete<_Action>(
      context,
      deleteCallback: product.remove,
      deleteValue: _Action.delete,
      popAfterDeleted: true,
      warningContent: Text(S.dialogDeletionContent(product.name, '')),
      actions: <BottomSheetAction<_Action>>[
        BottomSheetAction(
          title: Text(S.menuProductUpdate),
          leading: const Icon(Icons.text_fields_sharp),
          navigateArgument: product,
          navigateRoute: Routes.menuProductModal,
        ),
        const BottomSheetAction(
          title: Text('更新照片'),
          leading: Icon(Icons.image_sharp),
          returnValue: _Action.changeImage,
        ),
      ],
    );

    if (result == _Action.changeImage) {
      await product.pickImage();
    }
  }
}

enum _Action {
  delete,
  changeImage,
}
