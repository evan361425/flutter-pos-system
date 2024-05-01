import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slivers/sliver_image_app_bar.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/product_ingredient_view.dart';

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({
    super.key,
    required this.product,
  });

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
        tooltip: S.menuIngredientTitleCreate,
        child: const Icon(KIcons.add),
      ),
      body: CustomScrollView(slivers: [
        SliverImageAppBar(
          model: widget.product,
          actions: [
            MoreButton(
              key: const Key('item_more_action'),
              onPressed: _showActions,
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MetaBlock.withString(context, <String>[
          S.menuProductMetaTitle,
          S.menuProductMetaPrice(widget.product.price),
          S.menuProductMetaCost(widget.product.cost),
        ])!,
      ),
    );
  }

  Iterable<Widget> get ingredientView {
    if (widget.product.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyBody(
            helperText: S.menuIngredientEmptyBody,
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
          // Floating action button offset
          (_, int index) => index == items.length ? const SizedBox(height: 72.0) : ProductIngredientView(items[index]),
          childCount: items.length + 1,
        ),
      ),
    ];
  }

  @override
  void initState() {
    widget.product.addListener(_reload);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // if change ingredient in product_ingredient_search
    context.watch<Stock>();
    // if change quantity in product_quantity_search
    context.watch<Quantities>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    widget.product.removeListener(_reload);
    super.dispose();
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
          title: Text(S.menuProductTitleUpdate),
          leading: const Icon(KIcons.modal),
          route: Routes.menuProductModal,
          routePathParameters: {'id': widget.product.id},
        ),
        BottomSheetAction(
          title: Text(S.menuProductTitleUpdateImage),
          leading: const Icon(KIcons.image),
          returnValue: _Action.changeImage,
        ),
      ],
    );

    if (result == _Action.changeImage && mounted) {
      await widget.product.pickImage(context);
    }
  }

  void _reload() {
    if (mounted) {
      setState(() {});
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
