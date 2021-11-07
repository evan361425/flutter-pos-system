import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slidable_item_list.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;

  const ProductList(this.products, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(kSpacing1),
        child: HintText(S.totalCount(products.length)),
      ),
      SlidableItemList<Product, _Action>(
        items: products,
        deleteValue: _Action.delete,
        actionBuilder: _actionBuilder,
        tileBuilder: _tileBuilder,
        warningContextBuilder: _warningContextBuilder,
        handleTap: _handleTap,
        handleDelete: (item) => item.remove(),
      ),
    ]);
  }

  Iterable<BottomSheetAction<_Action>> _actionBuilder(Product product) {
    return <BottomSheetAction<_Action>>[
      BottomSheetAction(
        title: Text(S.menuProductUpdate),
        leading: const Icon(Icons.text_fields_sharp),
        navigateRoute: Routes.menuProductModal,
        navigateArgument: product,
      ),
      BottomSheetAction(
        title: Text(S.menuProductReorder),
        leading: const Icon(Icons.reorder_sharp),
        navigateRoute: Routes.menuProductReorder,
        navigateArgument: product.catalog,
      ),
    ];
  }

  void _handleTap(BuildContext context, Product product) {
    Navigator.of(context).pushNamed(
      Routes.menuProduct,
      arguments: product,
    );
  }

  Widget _tileBuilder(BuildContext context, int index, Product product) {
    return ListTile(
      key: Key('product.${product.id}'),
      leading: CircleAvatar(
        child: Text(product.name.characters.first.toUpperCase()),
      ),
      title: Text(product.name, style: Theme.of(context).textTheme.headline6),
      subtitle: MetaBlock.withString(
        context,
        product.items.map((e) => e.name),
        emptyText: S.menuProductListEmptyIngredient,
      ),
    );
  }

  Widget _warningContextBuilder(BuildContext context, Product product) {
    return Text(S.dialogDeletionContent(product.name, ''));
  }
}

enum _Action {
  delete,
}
