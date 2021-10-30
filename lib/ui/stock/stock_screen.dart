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
import 'package:possystem/ui/stock/widgets/ingredient_list.dart';
import 'package:provider/provider.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<Stock>();

    navigateNewIngredient() =>
        Navigator.of(context).pushNamed(Routes.stockIngredient);

    return Scaffold(
      appBar: AppBar(
        title: Text(tt('home.stock')),
        leading: const PopButton(),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('stock.add'),
        onPressed: navigateNewIngredient,
        tooltip: tt('stock.ingredient.add'),
        child: const Icon(KIcons.add),
      ),
      // this page need to draw lots of data, wait a will to make sure page shown
      body: stock.isEmpty
          ? Center(child: EmptyBody(onPressed: navigateNewIngredient))
          : _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(children: [
          HintText('上次補貨時間：${Stock.instance.updatedDate ?? '無'}'),
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
                  showSuccessSnackbar(context, tt('succss'));
                }
              },
              child: const Text('設定採購'),
            ),
          ),
          HintText(tt('total_count', {'count': Stock.instance.length})),
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
