import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/ui/order/widgets/order_actions.dart';

import 'chart/chart_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => showCupertinoModalPopup(
            context: context,
            builder: (_) => OrderActions(),
          ),
          icon: Icon(KIcons.more),
        ),
        actions: [TextButton(onPressed: onOrder, child: Text('點餐'))],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleRowWrap(children: <Widget>[
            for (var catalog in ['hambuger', 'sandwitch', 'drink'])
              RadioText(
                onSelected: () {},
                groupId: 'order.catalogs',
                value: catalog,
                child: Text(catalog),
              ),
          ]),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Wrap(
                    spacing: 4.0,
                    children: [
                      for (var product in ['cheeseburger', 'hameburger'])
                        RadioText(
                          onSelected: () {},
                          groupId: 'order.products',
                          value: product,
                          child: Text(product),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Card(
              child: ChartScreen(),
            ),
          ),
          SingleRowWrap(children: <Widget>[
            for (var ingredient in ['cheese', 'bread'])
              RadioText(
                onSelected: () {},
                groupId: 'order.ingredients',
                value: ingredient,
                child: Text(ingredient),
              ),
          ]),
          SingleRowWrap(children: <Widget>[
            for (var quantity in ['less', 'more'])
              RadioText(
                onSelected: () {},
                groupId: 'order.quantities',
                value: quantity,
                child: Text(quantity),
              ),
          ]),
        ],
      ),
    );
  }

  void onOrder() {}

  Future<void> showConfirmDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: '確定要回到菜單頁嗎？'),
    );

    if (result == true) Navigator.of(context).pop();
  }
}

class SingleRowWrap extends StatelessWidget {
  const SingleRowWrap({
    Key key,
    @required this.children,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Wrap(
            spacing: 4.0,
            children: children,
          ),
        ),
      ),
    );
  }
}
