import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slivers/sliver_image_app_bar.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/ingredient_expansion_card.dart';

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        key: const Key('product.add'),
        onPressed: _handleCreateIng,
        tooltip: S.menuIngredientCreate,
        child: const Icon(KIcons.add),
      ),
      body: CustomScrollView(slivers: [
        SliverImageAppBar(
          model: widget.product,
          actions: [
            IconButton(
              key: const Key('item_more_action'),
              onPressed: _showActions,
              enableFeedback: true,
              icon: const Icon(KIcons.more),
            ),
          ],
        ),
        metadata,
        ...ingredientView,
      ]),
    );
  }

  Widget get metadata {
    return SliverToBoxAdapter(
      child: MetaBlock.withString(context, <String>[
        S.menuProductMetaTitle,
        S.menuProductMetaPrice(widget.product.price),
        S.menuProductMetaCost(widget.product.cost),
      ])!,
    );
  }

  Iterable<Widget> get ingredientView {
    if (widget.product.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyBody(
            title: S.menuProductEmptyBody,
            onPressed: _handleCreateIng,
          ),
        )
      ];
    }

    // get the ordered items
    final items = widget.product.itemList;
    return [
      SliverToBoxAdapter(
        child: Center(child: HintText(S.totalCount(items.length))),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, int index) => IngredientExpansionCard(items[index]),
          childCount: items.length,
        ),
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    widget.product.addListener(() => setState(() {}));
    // if change ingredient in product_ingredient_search
    context.watch<Stock>();
    // if change quantity in product_quantity_search
    context.watch<Quantities>();
    super.didChangeDependencies();
  }

  void _showActions() async {
    final result = await BottomSheetActions.withDelete<_Action>(
      context,
      deleteCallback: widget.product.remove,
      deleteValue: _Action.delete,
      popAfterDeleted: true,
      warningContent: Text(S.dialogDeletionContent(widget.product.name, '')),
      actions: <BottomSheetAction<_Action>>[
        BottomSheetAction(
          title: Text(S.menuProductUpdate),
          leading: const Icon(Icons.text_fields_sharp),
          route: Routes.menuProductModal,
          routePathParameters: {'id': widget.product.id},
        ),
        const BottomSheetAction(
          title: Text('更新照片'),
          leading: Icon(Icons.image_sharp),
          returnValue: _Action.changeImage,
        ),
      ],
    );

    if (result == _Action.changeImage && context.mounted) {
      await widget.product.pickImage(context);
    }
  }

  void _handleCreateIng() {
    context.pushNamed(
      Routes.menuProductDetails,
      pathParameters: {'id': widget.product.id},
    );
  }
}

enum _Action {
  delete,
  changeImage,
}
