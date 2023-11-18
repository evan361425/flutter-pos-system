import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/checkout_warning.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/settings/order_outlook_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cart/cart_metadata_view.dart';
import 'package:possystem/ui/order/cart/cart_product_list.dart';
import 'package:possystem/ui/order/cart/cart_product_selector.dart';
import 'package:wakelock/wakelock.dart';

import 'cart/cart_product_state_selector.dart';
import 'widgets/order_actions.dart';
import 'widgets/orientated_view.dart';
import 'widgets/draggable_sheet_view.dart';
import 'widgets/order_catalog_list_view.dart';
import 'widgets/order_product_list_view.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  late final PageController _pageController;
  late final ValueNotifier<int> _catalogIndexNotifier;

  @override
  Widget build(BuildContext context) {
    final catalogs = Menu.instance.notEmptyItems;

    final orderCatalogListView = OrderCatalogListView(
      catalogs: catalogs,
      indexNotifier: _catalogIndexNotifier,
      onSelected: (index) => _pageController.jumpToPage(index),
    );
    final orderProductListView = PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => _catalogIndexNotifier.value = index,
      itemCount: catalogs.length,
      itemBuilder: (context, index) {
        return OrderProductListView(products: catalogs[index].itemList);
      },
    );

    final outlook = SettingsProvider.of<OrderOutlookSetting>();

    return TutorialWrapper(
      child: DraggableScrollableActuator(
        child: Scaffold(
          // avoid resize when keyboard(bottom inset) shows
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: const PopButton(),
            actions: [
              const OrderActions(key: Key('order.more')),
              Builder(builder: (context) {
                // allow it to access descendent DraggableScrollableSheet.
                return TextButton(
                  key: const Key('order.checkout'),
                  onPressed: () => _handleCheckout(context),
                  child: Text(S.orderActionsCheckout),
                );
              }),
            ],
          ),
          body: outlook.value == OrderOutlookTypes.slidingPanel
              ? DraggableSheetView(
                  row1: orderCatalogListView,
                  row2: orderProductListView,
                  row3_1: const CartProductSelector(),
                  row3_2Builder: (scroll) => Expanded(
                    child: CartProductList(
                      scrollController: scroll,
                    ),
                  ),
                  row3_3: const CartMetadataView(),
                  row4: const CartProductStateSelector(),
                )
              : OrientatedView(
                  row1: orderCatalogListView,
                  row2: orderProductListView,
                  row3_1: const CartProductSelector(),
                  row3_2: const Expanded(child: CartProductList()),
                  row3_3: const CartMetadataView(),
                  row4: const CartProductStateSelector(),
                ),
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

    _pageController = PageController();
    _catalogIndexNotifier = ValueNotifier<int>(0);
    super.initState();
  }

  void _handleCheckout(BuildContext context) async {
    final status = await context.pushNamed<CheckoutStatus>(Routes.orderDetails);
    if (status != null && context.mounted) {
      handleCheckoutStatus(context, status);
      DraggableScrollableActuator.reset(context);
    }
  }
}

void handleCheckoutStatus(BuildContext context, CheckoutStatus status) {
  status = SettingsProvider.of<CheckoutWarningSetting>().shouldShow(status);

  switch (status) {
    case CheckoutStatus.ok:
    case CheckoutStatus.stash:
    case CheckoutStatus.restore:
      showSnackBar(context, S.actSuccess);
      break;
    case CheckoutStatus.cashierNotEnough:
      showSnackBar(context, S.orderCashierPaidNotEnough);
      break;
    case CheckoutStatus.cashierUsingSmall:
      showMoreInfoSnackBar(
        context,
        S.orderCashierPaidUsingSmallMoney,
        Text(S.orderCashierPaidUsingSmallMoneyHint),
      );
      break;
    default:
  }
}
