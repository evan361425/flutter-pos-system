import 'package:flutter/material.dart';
import 'package:possystem/components/circular_loading.dart';
import 'package:possystem/components/empty_body.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/helpers/custom_styles.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/stock/widgets/ingredient_list.dart';
import 'package:possystem/ui/stock/widgets/stock_batch_actions.dart';
import 'package:provider/provider.dart';

class StockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed(
            Routes.stockIngredient,
          ),
          tooltip: '新增成份',
          child: Icon(KIcons.add),
        ),
        body: FutureBuilder<bool>(
          future: Future.delayed(Duration(milliseconds: 10), () => true),
          builder: (context, snapshot) {
            return snapshot.hasData ? _body(context) : CircularLoading();
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final stock = context.watch<StockModel>();
    if (!stock.isReady) return CircularLoading();
    if (stock.isEmpty) {
      return Center(child: EmptyBody('stock.empty'));
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: StockBatchActions(),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: _metadata(context),
      ),
      Expanded(
        child: SingleChildScrollView(
          child: IngredientList(ingredients: stock.ingredientList),
        ),
      ),
    ]);
  }

  Widget _metadata(BuildContext context) {
    final captionStyle = Theme.of(context).textTheme.muted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          child: Row(
            children: [
              Icon(
                Icons.store_sharp,
                size: captionStyle.fontSize,
                color: captionStyle.color,
              ),
              Text(
                '現在庫存的數量',
                style: captionStyle,
                overflow: TextOverflow.ellipsis,
              ),
              MetaBlock(),
              Icon(
                Icons.shopping_cart_sharp,
                size: captionStyle.fontSize,
                color: captionStyle.color,
              ),
              Text(
                '上次補貨後的數量',
                style: captionStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Tooltip(
            message: '上次修改時間',
            child: Icon(
              Icons.access_time,
              size: captionStyle.fontSize,
              color: captionStyle.color,
            ),
          ),
        ),
        Text(
          StockModel.instance.updatedDate ?? '尚未開始設定',
          style: captionStyle,
        ),
      ],
    );
  }
}
