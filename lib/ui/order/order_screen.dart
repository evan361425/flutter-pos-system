import 'package:flutter/material.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/order_outlook_setting.dart';
import 'package:possystem/settings/setting.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

import 'cart/cart_product_list.dart';
import 'cart/cart_screen.dart';
import 'widgets/order_actions.dart';
import 'widgets/order_by_orientation.dart';
import 'widgets/order_by_sliding_panel.dart';
import 'widgets/order_catalog_list.dart';
import 'widgets/order_product_state_selector.dart';
import 'widgets/order_product_list.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> with RouteAware {
  final _orderProductList = GlobalKey<OrderProductListState>();
  final _cartProductList = GlobalKey<CartProductListState>();
  final slidingPanel = GlobalKey<OrderBySlidingPanelState>();

  @override
  Widget build(BuildContext context) {
    final catalogs = Menu.instance.notEmptyItems;

    final menuCatalogRow = OrderCatalogList(
      catalogs: catalogs,
      handleSelected: (catalog) =>
          _orderProductList.currentState?.updateProducts(catalog),
    );
    final menuProductRow = OrderProductList(
      key: _orderProductList,
      products: catalogs.isEmpty ? const [] : catalogs.first.itemList,
      handleSelected: (_) => _cartProductList.currentState?.scrollToBottom(),
    );
    final cartProductRow = ChangeNotifierProvider<Cart>.value(
      value: Cart.instance,
      child: CartScreen(productsKey: _cartProductList),
    );
    final menuIngredientRow = MultiProvider(
      providers: [
        ChangeNotifierProvider<Cart>.value(value: Cart.instance),
        ChangeNotifierProvider<CartIngredients>.value(
            value: CartIngredients.instance),
      ],
      child: OrderProductStateSelector(),
    );

    final outlook = SettingsProvider.instance.getSetting<OrderOutlookSetting>();

    return Scaffold(
      // avoid resize when keyboard(bottom inset) shows
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const OrderActions(key: Key('order.action.more')),
        actions: [
          AppbarTextButton(
            key: const Key('order.cashier'),
            onPressed: () => _handleOrder(),
            child: Text(S.orderActionsOrderDone),
          ),
        ],
      ),
      body: outlook.value == OrderOutlookTypes.slidingPanel
          ? OrderBySlidingPanel(
              key: slidingPanel,
              row1: menuCatalogRow,
              row2: menuProductRow,
              row3: cartProductRow,
              row4: menuIngredientRow,
            )
          : OrderByOrientation(
              row1: menuCatalogRow,
              row2: menuProductRow,
              row3: cartProductRow,
              row4: menuIngredientRow,
            ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MyApp.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPop() {
    Wakelock.disable();
    super.didPop();
  }

  @override
  void didPush() {
    if (SettingsProvider.instance.getSetting<OrderAwakeningSetting>().value) {
      Wakelock.enable();
    }
    // rebind menu/customer_setting if changed
    Cart.instance.rebind();
    super.didPush();
  }

  @override
  void dispose() {
    MyApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _handleOrder() async {
    final route = CustomerSettings.instance.hasSelectableSetting
        ? Routes.orderCustomer
        : Routes.orderCalculator;
    var result = await Navigator.of(context).pushNamed(route);
    if (result is String) {
      result = await Navigator.of(context).pushNamed(result);
    }

    if (result == true) {
      showSuccessSnackbar(context, S.actSuccess);
      slidingPanel.currentState?.reset();
    }
  }
}
