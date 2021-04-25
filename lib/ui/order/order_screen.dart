import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/single_row_warp.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/ui/order/cashier/calculator_dialog.dart';
import 'package:possystem/ui/order/widgets/ingredient_selection.dart';
import 'package:possystem/ui/order/widgets/order_actions.dart';
import 'package:possystem/ui/order/widgets/product_selection.dart';
import 'package:provider/provider.dart';

import 'cart/cart_product_list.dart';
import 'cart/cart_screen.dart';

class OrderScreen extends StatelessWidget {
  static final productSelection = GlobalKey<ProductSelectionState>();
  static final productsKey = GlobalKey<CartProductListState>();

  const OrderScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menu = context.read<MenuModel>();
    final catalogs = menu.catalogList.where((catalog) => catalog.isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            final result = await showCupertinoModalPopup<OrderActionTypes>(
              context: context,
              builder: (_) => OrderActions(),
            );
            onAction(context, result);
          },
          icon: Icon(KIcons.more),
        ),
        actions: [
          TextButton(
            onPressed: () => onOrder(context),
            child: Text('點餐'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleRowWrap(children: <Widget>[
            for (final catalog in catalogs)
              RadioText(
                onSelected: () {
                  productSelection.currentState.catalog = catalog;
                },
                groupId: 'order.catalogs',
                value: catalog.id,
                child: Text(catalog.name),
              ),
          ]),
          Expanded(
            child: ProductSelection(
              key: productSelection,
              catalog: catalogs.first,
              productsKey: productsKey,
            ),
          ),
          Expanded(
            flex: 3,
            child: Card(
              child: ChangeNotifierProvider.value(
                value: CartModel.instance,
                builder: (_, __) => CartScreen(productsKey: productsKey),
              ),
            ),
          ),
          IngredientSelection(),
        ],
      ),
    );
  }

  void onOrder(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => CalculatorDialog(),
    );
  }

  void onAction(BuildContext context, OrderActionTypes action) {
    switch (action) {
      case OrderActionTypes.leave:
        showConfirmDialog(context);
        return;
      case OrderActionTypes.pop_stash:
        return print('pop');
      case OrderActionTypes.stash:
        return print('stash');
    }
  }

  Future<void> showConfirmDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(title: '確定要回到菜單頁嗎？'),
    );

    if (result == true) Navigator.of(context).pop();
  }
}
