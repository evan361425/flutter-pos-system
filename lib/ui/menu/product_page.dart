import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slivers/sliver_image_app_bar.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/more_button.dart';
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
            title: S.menuProductEmptyBody,
            helperText: '你可以在產品中設定成分等資訊，例如：\n'
                '「起司漢堡」有「起司」、「麵包」等成分',
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
          (_, int index) => index == items.length
              ? const SizedBox(height: 72.0)
              : ProductIngredientView(items[index]),
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
          title: Text(S.menuProductUpdate),
          leading: const Icon(KIcons.modal),
          route: Routes.menuProductModal,
          routePathParameters: {'id': widget.product.id},
        ),
        const BottomSheetAction(
          title: Text('更新照片'),
          leading: Icon(KIcons.image),
          returnValue: _Action.changeImage,
        ),
      ],
    );

    if (result == _Action.changeImage && context.mounted) {
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
