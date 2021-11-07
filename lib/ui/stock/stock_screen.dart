import 'package:flutter/material.dart';
import 'package:possystem/components/style/empty_body.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tip/tip_tutorial.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'widgets/ingredient_list.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<Stock>();

    navigateNewIngredient() =>
        Navigator.of(context).pushNamed(Routes.stockIngredient);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.stockTitle),
        leading: const PopButton(),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('stock.add'),
        onPressed: navigateNewIngredient,
        tooltip: S.stockIngredientCreate,
        child: const Icon(KIcons.add),
      ),
      // this page need to draw lots of data, wait a will to make sure page shown
      body: stock.isEmpty
          ? Center(child: EmptyBody(onPressed: navigateNewIngredient))
          : _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final updatedAt = Stock.instance.updatedAt;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(children: [
          HintText(updatedAt == null
              ? S.stockHasNotReplenishEver
              : S.stockUpdatedAt(updatedAt)),
          TipTutorial(
            label: 'replenishment.apply',
            message: '你不需要一個一個去設定庫存，馬上設定採購，一次設定多個成份吧！',
            child: TextButton(
              key: const Key('stock.replenisher'),
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  Routes.stockReplenishment,
                );

                if (result == true) {
                  showSuccessSnackbar(context, S.actSuccess);
                }
              },
              child: const Text('設定採購'),
            ),
          ),
          HintText(S.totalCount(Stock.instance.length)),
        ]),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: IngredientList(ingredients: Stock.instance.itemList),
        ),
      ),
    ]);
  }
}
