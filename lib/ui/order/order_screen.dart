import 'package:flutter/material.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/order_outlook_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
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
  const OrderScreen({Key? key}) : super(key: key);

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
    final menuProductRow = Tooltip(
      message: '透過圖片點餐更方便！\n你也可以到「設定」頁面設定「每行顯示幾個產品」或僅使用文字點餐',
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
    final orderProductStateSelector = MultiProvider(
      providers: [
        ChangeNotifierProvider<Cart>.value(value: Cart.instance),
        ChangeNotifierProvider<CartIngredients>.value(
            value: CartIngredients.instance),
      ],
      child: OrderProductStateSelector(),
    );

    final outlook = SettingsProvider.of<OrderOutlookSetting>();

    return Scaffold(
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
              row4: orderProductStateSelector,
            )
          : OrderByOrientation(
              row1: menuCatalogRow,
              row2: menuProductRow,
              row3: cartProductRow,
              row4: orderProductStateSelector,
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
    if (SettingsProvider.of<OrderAwakeningSetting>().value) {
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

    if (result is CashierUpdateStatus) {
      switch (result) {
        case CashierUpdateStatus.ok:
          showSuccessSnackbar(context, S.actSuccess);
          break;
        case CashierUpdateStatus.notEnough:
          showErrorSnackbar(context, '收銀機錢不夠找囉！');
          break;
        case CashierUpdateStatus.usingSmall:
          showInfoSnackbar(
            context,
            '收銀機使用小錢去找零！',
            SnackBarAction(
              key: const Key('order.cashierUsingSmallAction'),
              label: '啥？',
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const SimpleDialog(
                  key: Key('order.cashierUsingSmallAction.tip'),
                  title: Text('收銀機使用小錢去找零'),
                  contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 16),
                  children: [
                    Text('當找的錢不夠用最適合的錢去找的時候會顯示這個訊息。\n\n'
                        '例如，售價「65」，消費者支付「100」，此時應找「35」\n'
                        '如果收銀機只有 2 個十元，但是有 3 個以上的五元，就會顯示本訊息。'),
                    SizedBox(height: 8.0),
                    Text('這時你可以：\n'
                        '• 換錢\n'
                        '• 到設定頁關閉收銀機的相關提示'),
                  ],
                ),
              ),
            ),
          );
          break;
      }
      slidingPanel.currentState?.reset();
    }
  }
}
