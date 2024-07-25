import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/widgets/stock_ingredient_list.dart';

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
          child: StockIngredientList(leading: _buildActions()),
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

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Material(
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
        ),
      ]),
    );
  }
}
