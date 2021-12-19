import 'package:flutter/material.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/order_outlook_setting.dart';
import 'package:possystem/settings/setting.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:simple_tip/simple_tip.dart';
import 'package:wakelock/wakelock.dart';

import 'cart/cart_product_list.dart';
import 'cart/cart_screen.dart';
import 'widgets/order_actions.dart';
import 'widgets/order_by_orientation.dart';
import 'widgets/order_by_sliding_panel.dart';
import 'widgets/order_catalog_list.dart';
import 'widgets/order_product_list.dart';
import 'widgets/order_product_state_selector.dart';

class OrderScreen extends StatefulWidget {
  final RouteObserver<ModalRoute<void>>? routeObserver;

  final GlobalKey<TipGrouperState>? tipGrouper;

  const OrderScreen({
    Key? key,
    this.tipGrouper,
    this.routeObserver,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
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
    final menuProductRow = OrderedTip(
      id: 'product_list',
      grouper: widget.tipGrouper,
      message: '透過圖片點餐更方便！\n你也可以到「設定」頁面設定「每行顯示幾個產品」或僅使用文字點餐',
      order: 1000,
      version: catalogs.isEmpty ? 0 : 1,
      child: OrderProductList(
        key: _orderProductList,
        products: catalogs.isEmpty ? const [] : catalogs.first.itemList,
        handleSelected: (_) => _cartProductList.currentState?.scrollToBottom(),
      ),
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

    return TipGrouper(
      key: widget.tipGrouper,
      id: 'order',
      candidateLength: 1,
      routeObserver: widget.routeObserver,
      child: Scaffold(
        // avoid resize when keyboard(bottom inset) shows
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: const PopButton(),
          actions: [
            const OrderActions(key: Key('order.action.more')),
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
                tipGrouper: widget.tipGrouper,
              )
            : OrderByOrientation(
                row1: menuCatalogRow,
                row2: menuProductRow,
                row3: cartProductRow,
                row4: menuIngredientRow,
              ),
      ),
    );
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  @override
  void initState() {
    if (SettingsProvider.instance.getSetting<OrderAwakeningSetting>().value) {
      Wakelock.enable();
    }
    // rebind menu/customer_setting if changed
    Cart.instance.rebind();
    super.initState();
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
