import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/widgets/stock_ingredient_list.dart';

class StockView extends StatefulWidget {
  final int? tabIndex;

  const StockView({super.key, this.tabIndex});

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
        key: const Key('stock.empty'),
        child: EmptyBody(
          helperText: '新增成份後，就可以開始追蹤這些成份的庫存囉！',
          onPressed: () => context.pushNamed(Routes.ingredientNew),
        ),
      );
    }

    return TutorialWrapper(
      tab: tab,
      child: ListView(padding: const EdgeInsets.only(bottom: 76), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Tutorial(
            id: 'stock.replenishment',
            index: 1,
            title: S.stockReplenishmentTutorialTitle,
            message: S.stockReplenishmentTutorialMessage,
            child: RouteCircularButton(
              key: const Key('stock.replenisher'),
              icon: Icons.shopping_basket_sharp,
              route: Routes.replenishment,
              popTrueShowSuccess: true,
              text: S.stockReplenishmentButton,
            ),
          ),
          const SizedBox.square(dimension: 96.0),
          Tutorial(
            id: 'stock.add',
            index: 0,
            disable: Stock.instance.isNotEmpty,
            title: S.stockIngredientAddTutorialTitle,
            message: S.stockIngredientAddTutorialMessage,
            child: RouteCircularButton(
              key: const Key('stock.add'),
              route: Routes.ingredientNew,
              icon: KIcons.add,
              text: S.stockIngredientCreate,
            ),
          ),
        ]),
        const SizedBox(height: 4.0),
        ListenableBuilder(
          listenable: Stock.instance,
          builder: (context, child) {
            return StockIngredientList(ingredients: Stock.instance.itemList);
          },
        ),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    tab = widget.tabIndex == null ? null : TutorialInTab(index: widget.tabIndex!, context: context);

    super.initState();
  }
}
