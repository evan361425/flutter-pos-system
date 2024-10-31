import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/route_buttons.dart';
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

    // when stock is not empty, we use [ListenableBuilder] to listen to the
    // stock changes.
    if (context.select<Stock, bool>((Stock stock) => stock.isEmpty)) {
      return Center(
        child: EmptyBody(
          content: S.stockIngredientEmptyBody,
          routeName: Routes.stockIngrCreate,
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  kHorizontalSpacing,
                  kInternalSpacing,
                  kHorizontalSpacing,
                  kInternalSpacing,
                ),
                child: Row(children: [
                  Expanded(
                    child: RouteElevatedIconButton(
                      key: const Key('stock.add'),
                      icon: const Icon(KIcons.add),
                      label: S.stockIngredientTitleCreate,
                      route: Routes.stockIngrCreate,
                    ),
                  ),
                ]),
              ),
              for (final item in Stock.instance.itemList) StockIngredientListTile(item: item),
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
    return ButtonGroup(buttons: [
      Tutorial(
        id: 'stock.replenishment',
        title: S.stockReplenishmentTutorialTitle,
        message: S.stockReplenishmentTutorialContent,
        preferVertical: true,
        child: RouteIconButton(
          key: const Key('stock.replenisher'),
          icon: const Icon(Icons.shopping_basket_outlined),
          route: Routes.stockRepl,
          popTrueShowSuccess: true,
          label: S.stockReplenishmentButton,
        ),
      )
    ]);
  }
}
