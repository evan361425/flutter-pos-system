import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ProductIngredientView extends StatelessWidget {
  final ProductIngredient ingredient;

  const ProductIngredientView(
    this.ingredient, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = 'product_ingredient.${ingredient.id}';
    return ExpansionTile(
      key: Key(key),
      title: Text(ingredient.name),
      subtitle: Text(S.menuIngredientMetaAmount(ingredient.amount)),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          key: Key('$key.add'),
          leading: const CircleAvatar(child: Icon(KIcons.add)),
          title: Text(S.menuQuantityCreate),
          onTap: () => context.pushNamed(
            Routes.menuProductDetails,
            pathParameters: {'id': ingredient.product.id},
            queryParameters: {'iid': ingredient.id, 'qid': ''},
          ),
          trailing: IconButton(
            key: Key('$key.more'),
            onPressed: () => showActions(context),
            enableFeedback: true,
            icon: const Icon(KIcons.more),
          ),
        ),
        for (final item in ingredient.items) _QuantityTile(item),
      ],
    );
  }

  void showActions(BuildContext context) {
    BottomSheetActions.withDelete<int>(
      context,
      deleteValue: 0,
      actions: <BottomSheetAction<int>>[
        BottomSheetAction(
          title: Text(S.menuIngredientUpdate),
          leading: const Icon(KIcons.modal),
          route: Routes.menuProductDetails,
          routePathParameters: {'id': ingredient.product.id},
          routeQueryParameters: {'iid': ingredient.id},
        ),
      ],
      warningContent: Text(S.dialogDeletionContent(ingredient.name, '')),
      deleteCallback: () => ingredient.remove(),
    );
  }
}

class _QuantityTile extends StatelessWidget {
  final ProductQuantity quantity;

  const _QuantityTile(this.quantity);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('product_quantity.${quantity.id}'),
      title: Text(quantity.name),
      subtitle: MetaBlock.withString(context, <String>[
        S.menuQuantityMetaAmount(quantity.amount),
        S.menuQuantityMetaPrice(quantity.additionalPrice),
        S.menuQuantityMetaCost(quantity.additionalCost),
      ]),
      onLongPress: () => BottomSheetActions.withDelete<int>(
        context,
        deleteValue: 0,
        warningContent: Text(S.dialogDeletionContent(quantity.name, '')),
        deleteCallback: quantity.remove,
      ),
      onTap: () => context.pushNamed(
        Routes.menuProductDetails,
        pathParameters: {'id': quantity.ingredient.product.id},
        queryParameters: {
          'iid': quantity.ingredient.id,
          'qid': quantity.id,
        },
      ),
    );
  }
}
