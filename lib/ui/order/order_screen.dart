import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cashier/calculator_dialog.dart';
import 'package:possystem/ui/order/widgets/order_actions.dart';
import 'package:possystem/ui/order/widgets/order_ingredient_list.dart';
import 'package:possystem/ui/order/widgets/order_product_list.dart';
import 'package:provider/provider.dart';

import 'cart/cart_product_list.dart';
import 'cart/cart_screen.dart';
import 'widgets/order_catalog_list.dart';

class OrderScreen extends StatelessWidget {
  static final _orderProductList = GlobalKey<OrderProductListState>();
  static final _cartProductList = GlobalKey<CartProductListState>();

  const OrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<Menu>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            final result = await showCircularBottomSheet<OrderActionTypes>(
              context,
              actions: OrderActions.actions(),
            );
            await OrderActions.onAction(context, result);
          },
          icon: Icon(KIcons.more),
        ),
        actions: [
          AppbarTextButton(
            key: Key('order.action.order'),
            onPressed: () => _handleOrder(context),
            child: Text(tt('order.action.order')),
          ),
        ],
      ),
      body: menu.setUpStockMode(context) ? _body(context) : Container(),
    );
  }

  Widget _body(BuildContext context) {
    final catalogs = Menu.instance.itemList;
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) =>
          orientation == Orientation.portrait
              ? _bodyPortrait(catalogs)
              : _bodyLandscape(catalogs),
    );
  }

  Widget _bodyLandscape(List<Catalog> catalogs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300.0),
            child: Column(
              children: [
                Expanded(child: _cart()),
                OrderIngredientList(),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _catalogsRow(catalogs),
              Expanded(child: _productRow(catalogs)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bodyPortrait(List<Catalog> catalogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _catalogsRow(catalogs),
        Expanded(child: _productRow(catalogs)),
        Expanded(flex: 3, child: _cart()),
        OrderIngredientList(),
      ],
    );
  }

  Card _cart() {
    return Card(
      child: ChangeNotifierProvider.value(
        value: Cart.instance,
        builder: (_, __) => CartScreen(productsKey: _cartProductList),
      ),
    );
  }

  Widget _catalogsRow(List<Catalog> catalogs) {
    return OrderCatalogList(
      catalogs: catalogs,
      handleSelected: (catalog) =>
          _orderProductList.currentState?.updateProducts(catalog),
    );
  }

  void _handleOrder(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CalculatorDialog(),
    );

    if (result == true) {
      showSuccessSnackbar(context, tt('success'));
    }
  }

  Widget _productRow(List<Catalog> catalogs) {
    return OrderProductList(
      key: _orderProductList,
      products: catalogs.isEmpty ? const [] : catalogs.first.itemList,
      handleSelected: (_) => _cartProductList.currentState?.scrollToBottom(),
    );
  }
}
