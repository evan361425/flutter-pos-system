import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/slivers/sliver_image_app_bar.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/route_buttons.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';
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
    final size = MediaQuery.sizeOf(context);
    final dialog = size.width > Breakpoint.medium.max;

    return dialog ? _buildDialog() : _buildFullScreen();
  }

  Widget _buildFullScreen() {
    // get the ordered items
    final items = widget.product.itemList;
    return Dialog.fullscreen(
      child: Scaffold(
        primary: false,
        floatingActionButton: FloatingActionButton(
          key: const Key('product.add'),
          heroTag: null,
          onPressed: _handleCreateIng,
          tooltip: S.menuIngredientTitleCreate,
          child: const Icon(KIcons.add),
        ),
        body: CustomScrollView(slivers: [
          SliverImageAppBar(
            model: widget.product,
            actions: [_buildActionButton()],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(kHorizontalSpacing, kTopSpacing, kHorizontalSpacing, kInternalSpacing),
              child: _buildMetadata(),
            ),
          ),
          SliverToBoxAdapter(child: _buildIngredientTitle()),
          if (items.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(bottom: kFABSpacing),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, int index) => ProductIngredientView(items[index]),
                  childCount: items.length,
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildDialog() {
    final metadataTile = Row(children: [
      // change the image opacity with animation
      AnimatedContainer(
        constraints: const BoxConstraints(
          minHeight: 100,
          minWidth: 100,
          maxWidth: 140,
          maxHeight: 140,
        ),
        duration: kThemeChangeDuration,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: widget.product.image,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
          shape: BoxShape.rectangle,
        ),
      ),
      const SizedBox(width: kInternalLargeSpacing),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.product.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: kInternalSpacing),
          _buildMetadata(),
        ]),
      ),
      _buildActionButton(),
    ]);

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      scrollable: true,
      content: ConstrainedBox(
        constraints: BoxConstraints(minWidth: Breakpoint.compact.max),
        child: Column(children: [
          metadataTile,
          _buildIngredientTitle(),
          if (widget.product.isNotEmpty)
            for (final item in widget.product.itemList) ProductIngredientView(item),
          const SizedBox(height: kFABSpacing),
        ]),
      ),
    );
  }

  Widget _buildMetadata() {
    return MetaBlock.withString(context, <String>[
      S.menuProductMetaTitle,
      S.menuProductMetaPrice(widget.product.price),
      S.menuProductMetaCost(widget.product.cost),
    ])!;
  }

  Widget _buildIngredientTitle() {
    if (widget.product.isEmpty) {
      return EmptyBody(
        content: S.menuIngredientEmptyBody,
        onPressed: _handleCreateIng,
      );
    }

    return Row(children: [
      Expanded(
        child: Center(child: HintText(S.totalCount(widget.product.length))),
      ),
      RouteIconButton(
        key: const Key('product.reorder'),
        label: S.menuIngredientTitleReorder,
        icon: const Icon(KIcons.reorder),
        route: Routes.menuProductReorderIngredient,
        pathParameters: {'id': widget.product.id},
        hideLabel: true,
      ),
    ]);
  }

  Widget _buildActionButton() {
    return MoreButton(
      key: const Key('item_more_action'),
      onPressed: _showActions,
    );
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

  void _showActions(BuildContext context) async {
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
          route: Routes.menuProductUpdate,
          routePathParameters: {'id': widget.product.id},
        ),
        BottomSheetAction(
          title: Text(S.menuProductTitleUpdateImage),
          leading: const Icon(KIcons.image),
          returnValue: _Action.changeImage,
        ),
        BottomSheetAction(
          title: Text(S.menuIngredientTitleReorder),
          leading: const Icon(KIcons.reorder),
          route: Routes.menuProductReorderIngredient,
          routePathParameters: {'id': widget.product.id},
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
      Routes.menuProductUpdateIngredient,
      pathParameters: {'id': widget.product.id},
    );
  }
}

enum _Action {
  delete,
  changeImage,
}
