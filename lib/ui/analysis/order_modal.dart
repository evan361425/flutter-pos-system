import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:possystem/components/card_tile.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/providers/currency_provider.dart';

class OrderModal extends StatelessWidget {
  final OrderObject order;

  const OrderModal({Key key, @required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(KIcons.back)),
        // actions: [
        //   IconButton(
        //     onPressed: () =>
        //         showCupertinoModalPopup(context: context, builder: _actions),
        //     icon: Icon(KIcons.more),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(kSpacing2),
            child: _metadata(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                for (var product in order.products)
                  _productTile(context, product)
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _actions(BuildContext context) {
  //   return CupertinoActionSheet(
  //     actions: [
  //       CupertinoActionSheetAction(
  //         onPressed: () async {
  //           Navigator.of(context).pop();
  //           final needRecover = await showDialog(
  //             context: context,
  //             builder: (context) => _deleteDialog(context),
  //           );

  //           if (needRecover != null) {
  //             _handleDeletion(needRecover);
  //             // need use parent context to pop
  //           }
  //         },
  //         child: Text('刪除'),
  //       ),
  //     ],
  //     cancelButton: CupertinoActionSheetAction(
  //       onPressed: () => Navigator.pop(context, 'cancel'),
  //       child: Text('取消'),
  //     ),
  //   );
  // }

  Widget _metadata(BuildContext context) {
    // YYYY-MM-DD HH:mm:ss
    final createdAt = order.createdAt.toString().substring(0, 19);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MetaBlock.withString(context, [
          '售價：${CurrencyProvider.instance.numToString(order.totalPrice)}',
          '付款：${CurrencyProvider.instance.numToString(order.paid)}',
        ]),
        Text(createdAt)
      ],
    );
  }

  Widget _productTile(BuildContext context, OrderProductObject product) {
    final ingredients = product.ingredients.values.map((e) {
      final quantity = e.quantityName == null ? '' : '（${e.quantityName}）';
      return '${e.name}$quantity';
    });
    final price = product.singlePrice * product.count;

    return CardTile(
      title: Text('${product.productName} * ${product.count}'),
      subtitle: MetaBlock.withString(context, ingredients),
      trailing: Text(CurrencyProvider.instance.numToString(price)),
    );
  }

  // Widget _deleteDialog(BuildContext context) {
  //   var needRecover = true;
  //   return AlertDialog(
  //     title: Text('確認刪除通知'),
  //     content: SingleChildScrollView(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           Text('是否刪除本訂單記錄'),
  //           const SizedBox(height: kSpacing3),
  //           Text('注意：刪除後將無法復原', style: TextStyle(color: kNegativeColor)),
  //           StatefulBuilder(
  //             builder: (BuildContext context, StateSetter setState) =>
  //                 CheckboxListTile(
  //               controlAffinity: ListTileControlAffinity.leading,
  //               title: Text('復原成份庫存'),
  //               contentPadding: EdgeInsets.zero,
  //               value: needRecover,
  //               onChanged: (value) => setState(
  //                 () => needRecover = value,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     actions: <Widget>[
  //       TextButton(
  //         onPressed: () async {
  //           Navigator.of(context).pop(needRecover);
  //         },
  //         child: Text('刪除', style: TextStyle(color: kNegativeColor)),
  //       ),
  //       ElevatedButton(
  //         onPressed: () => Navigator.of(context).pop(),
  //         child: Text('取消'),
  //       ),
  //     ],
  //   );
  // }

  // void _handleDeletion(BuildContext context, bool needRecover) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('目前還未支持本功能..')),
  //   );
  // }
}
