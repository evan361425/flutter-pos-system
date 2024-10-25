import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/components/style/slide_to_delete.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ProductIngredientView extends StatelessWidget {
  final ProductIngredient ingredient;

  const ProductIngredientView(
    this.ingredient, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final key = 'product_ingredient.${ingredient.id}';
    return ExpansionTile(
      key: Key(key),
      title: Text(ingredient.name),
      subtitle: Text(S.menuIngredientMetaAmount(ingredient.amount)),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          const SizedBox(width: kHorizontalSpacing),
          Expanded(
            child: RouteElevatedIconButton(
              key: Key('$key.add'),
              icon: const Icon(KIcons.add),
              label: S.menuQuantityTitleCreate,
              route: Routes.menuProductUpdateIngredient,
              pathParameters: {'id': ingredient.product.id},
              queryParameters: {'iid': ingredient.id, 'qid': ''},
            ),
          ),
          EntryMoreButton(
            key: Key('$key.more'),
            onPressed: showActions,
          ),
          const SizedBox(width: kHorizontalSpacing),
        ]),
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
          title: Text(S.menuIngredientTitleUpdate),
          leading: const Icon(KIcons.modal),
          route: Routes.menuProductUpdateIngredient,
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
    return SlideToDelete(
      item: quantity,
      deleteCallback: _remove,
      warningContent: Text(S.dialogDeletionContent(quantity.name, '')),
      child: ListTile(
        key: Key('product_quantity.${quantity.id}'),
        title: Text(quantity.name),
        subtitle: MetaBlock.withString(context, <String>[
          S.menuQuantityMetaAmount(quantity.amount),
          S.menuQuantityMetaAdditionalPrice(quantity.additionalPrice.toCurrency()),
          S.menuQuantityMetaAdditionalCost(quantity.additionalCost.toCurrency()),
        ]),
        onLongPress: () => BottomSheetActions.withDelete<int>(
          context,
          deleteValue: 0,
          warningContent: Text(S.dialogDeletionContent(quantity.name, '')),
          deleteCallback: _remove,
        ),
        onTap: () => context.pushNamed(
          Routes.menuProductUpdateIngredient,
          pathParameters: {'id': quantity.ingredient.product.id},
          queryParameters: {
            'iid': quantity.ingredient.id,
            'qid': quantity.id,
          },
        ),
      ),
    );
  }

  Future<void> _remove() => quantity.remove();
}
