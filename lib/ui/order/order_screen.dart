import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/cashier_warning.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/order_outlook_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

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
  State<OrderScreen> createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  late final GlobalKey<OrderBySlidingPanelState> slidingPanel;
  late final PageController _pageController;
  late final ValueNotifier<int> _catalogIndexNotifier;

  @override
  Widget build(BuildContext context) {
    final catalogs = Menu.instance.notEmptyItems;

    final menuCatalogRow = OrderCatalogList(
      catalogs: catalogs,
      indexNotifier: _catalogIndexNotifier,
      onSelected: (index) => _pageController.jumpToPage(index),
    );
    final menuProductRow = PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => _catalogIndexNotifier.value = index,
      itemCount: catalogs.length,
      itemBuilder: (context, index) {
        return OrderProductList(products: catalogs[index].itemList);
      },
    );
    final cartProductRow = ChangeNotifierProvider<Cart>.value(
      value: Cart.instance,
      child: const CartScreen(),
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
          TextButton(
            key: const Key('order.apply'),
            onPressed: () => _onApply(),
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
    _pageController.dispose();
    _catalogIndexNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (SettingsProvider.of<OrderAwakeningSetting>().value) {
      Wakelock.enable();
    }
    // rebind menu/attributes if changed
    Cart.instance.rebind();

    slidingPanel = GlobalKey<OrderBySlidingPanelState>();
    _pageController = PageController();
    _catalogIndexNotifier = ValueNotifier<int>(0);
    super.initState();
  }

  void _onApply() async {
    final result = await Navigator.of(context).pushNamed(Routes.orderDetails);
    if (result is CashierUpdateStatus) {
      _showCashierWarning(result);
      slidingPanel.currentState?.reset();
    }
  }

  void _showCashierWarning(CashierUpdateStatus status) {
    status = SettingsProvider.of<CashierWarningSetting>().shouldShow(status);

    switch (status) {
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
            label: '說明',
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const SimpleDialog(
                key: Key('order.cashierUsingSmallAction.tip'),
                title: Text('收銀機使用小錢去找零'),
                contentPadding: EdgeInsets.fromLTRB(8, 12, 8, 16),
                children: [
                  Text('找錢給顧客時，收銀機無法使用最適合的錢，就會顯示這個訊息。\n\n'
                      '例如，售價「65」，消費者支付「100」，此時應找「35」\n'
                      '如果收銀機只有兩個十元，且有三個以上的五元，就會顯示本訊息。'),
                  SizedBox(height: 8.0),
                  Text('怎麼避免本提示：\n'
                      '• 到換錢頁面把各幣值補足。\n'
                      '• 到設定頁關閉收銀機的相關提示。'),
                ],
              ),
            ),
          ),
        );
        break;
    }
  }
}
