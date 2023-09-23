import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
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

import 'cart/cart_product_state_selector.dart';
import 'cart/cart_view.dart';
import 'widgets/order_actions.dart';
import 'widgets/orientated_view.dart';
import 'widgets/sliding_panel_view.dart';
import 'widgets/order_catalog_list_view.dart';
import 'widgets/order_product_list_view.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  late final GlobalKey<SlidingPanelViewState> slidingPanel;
  late final PageController _pageController;
  late final ValueNotifier<int> _catalogIndexNotifier;

  @override
  Widget build(BuildContext context) {
    final catalogs = Menu.instance.notEmptyItems;

    final menuCatalogRow = OrderCatalogListView(
      catalogs: catalogs,
      indexNotifier: _catalogIndexNotifier,
      onSelected: (index) => _pageController.jumpToPage(index),
    );
    final menuProductRow = PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => _catalogIndexNotifier.value = index,
      itemCount: catalogs.length,
      itemBuilder: (context, index) {
        return OrderProductListView(products: catalogs[index].itemList);
      },
    );
    final cartProductRow = ChangeNotifierProvider<Cart>.value(
      value: Cart.instance,
      child: const CartView(),
    );
    final orderProductStateSelector = MultiProvider(
      providers: [
        ChangeNotifierProvider<Cart>.value(value: Cart.instance),
        ChangeNotifierProvider<CartIngredients>.value(
            value: CartIngredients.instance),
      ],
      child: CartProductStateSelector(),
    );

    final outlook = SettingsProvider.of<OrderOutlookSetting>();

    return TutorialWrapper(
      child: Scaffold(
        // avoid resize when keyboard(bottom inset) shows
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: const PopButton(),
          actions: [
            const OrderActions(key: Key('order.action.more')),
            TextButton(
              key: const Key('order.apply'),
              onPressed: () => _onApply(),
              child: Text(S.orderActionsCheckout),
            ),
          ],
        ),
        body: outlook.value == OrderOutlookTypes.slidingPanel
            ? SlidingPanelView(
                key: slidingPanel,
                row1: menuCatalogRow,
                row2: menuProductRow,
                row3: cartProductRow,
                row4: orderProductStateSelector,
              )
            : OrientatedView(
                row1: menuCatalogRow,
                row2: menuProductRow,
                row3: cartProductRow,
                row4: orderProductStateSelector,
              ),
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

    slidingPanel = GlobalKey<SlidingPanelViewState>();
    _pageController = PageController();
    _catalogIndexNotifier = ValueNotifier<int>(0);
    super.initState();
  }

  void _onApply() async {
    final result = await context.pushNamed(Routes.orderDetails);
    if (result is CashierUpdateStatus) {
      _showCashierWarning(result);
      slidingPanel.currentState?.reset();
    }
  }

  void _showCashierWarning(CashierUpdateStatus status) {
    status = SettingsProvider.of<CashierWarningSetting>().shouldShow(status);

    switch (status) {
      case CashierUpdateStatus.ok:
        showSnackBar(context, S.actSuccess);
        break;
      case CashierUpdateStatus.notEnough:
        showSnackBar(context, S.orderCashierPaidNotEnough);
        break;
      case CashierUpdateStatus.usingSmall:
        showMoreInfoSnackBar(
          context,
          S.orderCashierPaidUsingSmallMoney,
          Text(S.orderCashierPaidUsingSmallMoneyHint),
          label: S.orderCashierPaidUsingSmallMoneyAction,
        );
        break;
    }
  }
}
