import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/repository/stock_model.dart';
import 'package:provider/provider.dart';

class StockMetadata extends StatelessWidget {
  const StockMetadata({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stock = context.read<StockModel>();
    final captionStyle = Theme.of(context).textTheme.caption;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.shopping_cart_sharp,
          size: captionStyle.fontSize,
          color: captionStyle.color,
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 2,
          child: Text('上次補貨後的數量', style: captionStyle),
        ),
        MetaBlock(),
        Icon(
          Icons.store_sharp,
          size: captionStyle.fontSize,
          color: captionStyle.color,
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 2,
          child: Text('現在庫存的數量', style: captionStyle),
        ),
        Spacer(),
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
        Text(stock.updatedDate ?? '尚未開始設定', style: captionStyle),
      ],
    );
  }
}
