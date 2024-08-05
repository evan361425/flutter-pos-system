import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/route_circular_button.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/stock/widgets/stock_ingredient_list_tile.dart';
import 'package:provider/provider.dart';

class StockView extends StatefulWidget {
  const StockView({super.key});

  @override
  State<StockView> createState() => _StockViewState();
}

class _StockViewState extends State<StockView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<Stock>();

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

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Breakpoint.medium.max),
        child: ListenableBuilder(
          listenable: Stock.instance,
          builder: (context, child) {
            return ListView(padding: const EdgeInsets.only(bottom: kFABSpacing, top: kTopSpacing), children: [
              Row(children: [
                Expanded(child: Center(child: _buildMeta())),
                _buildActions(),
                const SizedBox(width: kHorizontalSpacing),
              ]),
              const SizedBox(height: kInternalSpacing),
              for (final item in Stock.instance.itemList) StockIngredientListTile(item: item),
              ElevatedButton.icon(
                key: const Key('stock.add'),
                icon: const Icon(KIcons.add),
                label: Text(S.stockIngredientTitleCreate),
                onPressed: () => context.pushNamed(Routes.ingredientNew),
              ),
            ]);
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

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
    return Material(
      elevation: 1.0,
      borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      child: Tutorial(
        id: 'stock.replenishment',
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
    );
  }
}
