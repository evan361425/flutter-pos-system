import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/widgets/stock_ingredient_list_tile.dart';

class StockView extends StatefulWidget {
  final int? tabIndex;
  final bool circularActions;

  const StockView({
    super.key,
    this.tabIndex,
    this.circularActions = true,
  });

  @override
  State<StockView> createState() => _StockViewState();
}

class _StockViewState extends State<StockView> with AutomaticKeepAliveClientMixin {
  late final TutorialInTab? tab;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // after pop from AddPage, this page will rebuild by TabView
    // so we don't need to watch Stock.instance
    if (Stock.instance.isEmpty) {
      return Center(
        child: EmptyBody(
          content: S.stockIngredientEmptyBody,
          routeName: Routes.ingredientNew,
        ),
      );
    }

    return TutorialWrapper(
      tab: tab,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Breakpoint.medium.max),
          child: ListenableBuilder(
            listenable: Stock.instance,
            builder: (context, child) {
              return ListView(padding: const EdgeInsets.only(bottom: 76, top: 16), children: [
                if (widget.circularActions) _buildActions(),
                if (!widget.circularActions)
                  Row(children: [
                    Expanded(child: Center(child: _buildMeta())),
                    _buildActions(),
                    const SizedBox(width: 8.0),
                  ]),
                const SizedBox(height: 4.0),
                for (final item in Stock.instance.itemList) StockIngredientListTile(item: item),
              ]);
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    tab = widget.tabIndex == null ? null : TutorialInTab(index: widget.tabIndex!, context: context);

    super.initState();
  }

  Widget _buildMeta() {
    DateTime? latest;
    for (var ingredient in Stock.instance.items) {
      if (latest == null) {
        latest = ingredient.updatedAt;
      } else if (ingredient.updatedAt?.isAfter(latest) == true) {
        latest = ingredient.updatedAt;
      }
    }

    return HintText([
      latest == null ? S.stockReplenishmentNever : S.stockUpdatedAt(latest),
      S.totalCount(Stock.instance.length),
    ].join(MetaBlock.string));
  }

  Widget _buildActions() {
    if (widget.circularActions) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(
          child: Tutorial(
            id: 'stock.replenishment',
            index: 1,
            title: S.stockReplenishmentTutorialTitle,
            message: S.stockReplenishmentTutorialContent,
            child: RouteCircularButton(
              key: const Key('stock.replenisher'),
              icon: Icons.shopping_basket_sharp,
              route: Routes.replenishment,
              popTrueShowSuccess: true,
              text: S.stockReplenishmentButton,
            ),
          ),
        ),
        const Spacer(),
        Expanded(
          child: Tutorial(
            id: 'stock.add',
            index: 0,
            disable: Stock.instance.isNotEmpty,
            title: S.stockIngredientTutorialTitle,
            message: S.stockIngredientTutorialContent,
            child: RouteCircularButton(
              key: const Key('stock.add'),
              route: Routes.ingredientNew,
              icon: KIcons.add,
              text: S.stockIngredientTitleCreate,
            ),
          ),
        ),
      ]);
    }

    return Material(
      elevation: 1.0,
      borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      child: Row(children: [
        Tutorial(
          id: 'stock.replenishment',
          index: 1,
          title: S.stockReplenishmentTutorialTitle,
          message: S.stockReplenishmentTutorialContent,
          child: RouteIconButton(
            key: const Key('stock.replenisher'),
            icon: const Icon(Icons.shopping_basket_sharp),
            route: Routes.replenishment,
            popTrueShowSuccess: true,
            tooltip: S.stockReplenishmentButton,
          ),
        ),
        Tutorial(
          id: 'stock.add',
          index: 0,
          disable: Stock.instance.isNotEmpty,
          title: S.stockIngredientTutorialTitle,
          message: S.stockIngredientTutorialContent,
          child: RouteIconButton(
            key: const Key('stock.add'),
            route: Routes.ingredientNew,
            icon: const Icon(KIcons.add),
            tooltip: S.stockIngredientTitleCreate,
          ),
        ),
      ]),
    );
  }
}
