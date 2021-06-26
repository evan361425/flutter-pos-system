import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/radio_text.dart';
import 'package:possystem/components/style/single_row_warp.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/menu/catalog_model.dart';
import 'package:possystem/models/repository/cart_model.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/ui/home/home_screen.dart';
import 'package:possystem/ui/order/cashier/calculator_dialog.dart';
import 'package:possystem/ui/order/widgets/order_ingredient_list.dart';
import 'package:possystem/ui/order/widgets/order_actions.dart';
import 'package:possystem/ui/order/widgets/order_product_list.dart';
import 'package:provider/provider.dart';

import 'cart/cart_product_list.dart';
import 'cart/cart_screen.dart';

class OrderScreen extends StatelessWidget {
  static final productSelection = GlobalKey<OrderProductListState>();
  static final productsKey = GlobalKey<CartProductListState>();

  const OrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            final result = await showCircularBottomSheet<OrderActionTypes>(
              context,
              builder: (_) => OrderActions(),
            );
            await OrderActions.onAction(context, result);
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
      body: Routes.setUpStockMode(context) ? _body(context) : CircularLoading(),
    );
  }

  Widget _body(BuildContext context) {
    final catalogs = MenuModel.instance.itemList;
    return WillPopScope(
      onWillPop: () async {
        beforeLeave();
        return true;
      },
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) =>
            orientation == Orientation.portrait
                ? _bodyPortrait(catalogs)
                : _bodyLandscape(catalogs),
      ),
    );
  }

  Widget _bodyPortrait(List<CatalogModel> catalogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _catalogsRow(catalogs),
        Expanded(child: _menuProductList(catalogs)),
        Expanded(flex: 3, child: _cart()),
        OrderIngredientList(isPortrait: true),
      ],
    );
  }

  Widget _bodyLandscape(List<CatalogModel> catalogs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300.0),
            child: Column(
              children: [
                Expanded(child: _cart()),
                OrderIngredientList(isPortrait: false),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _catalogsRow(catalogs),
              Expanded(child: _menuProductList(catalogs)),
            ],
          ),
        ),
      ],
    );
  }

  Card _cart() {
    return Card(
      child: ChangeNotifierProvider.value(
        value: CartModel.instance,
        builder: (_, __) => CartScreen(productsKey: productsKey),
      ),
    );
  }

  Widget _menuProductList(List<CatalogModel> catalogs) {
    return OrderProductList(
      key: productSelection,
      catalog: catalogs.isEmpty ? null : catalogs.first,
      productsKey: productsKey,
    );
  }

  Widget _catalogsRow(List<CatalogModel> catalogs) {
    if (catalogs.isEmpty) {
      return SingleRowWrap(children: [RadioText.empty()]);
    }

    return SingleRowWrap(children: <Widget>[
      for (final catalog in catalogs)
        RadioText(
          onSelected: () {
            productSelection.currentState!.catalog = catalog;
          },
          groupId: 'order.catalogs',
          value: catalog.id,
          child: Text(catalog.name),
        ),
    ]);
  }

  void onOrder(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => CalculatorDialog(),
    );
  }

  static void beforeLeave() {
    HomeScreen.orderInfo.currentState?.reset();
  }
}
