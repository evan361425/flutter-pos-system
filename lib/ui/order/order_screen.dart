import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/providers/feature_provider.dart';
import 'package:possystem/providers/order_provider.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

import 'cart/cart_product_list.dart';
import 'cart/cart_screen.dart';
import 'widgets/order_actions.dart';
import 'widgets/order_by_orientation.dart';
import 'widgets/order_by_sliding_panel.dart';
import 'widgets/order_catalog_list.dart';
import 'widgets/order_ingredient_list.dart';
import 'widgets/order_product_list.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with RouteAware {
  final _orderProductList = GlobalKey<OrderProductListState>();
  final _cartProductList = GlobalKey<CartProductListState>();
  final _slidingPanel = GlobalKey<OrderBySlidingPanelState>();

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
    final cartProductRow = ChangeNotifierProvider.value(
      value: Cart.instance,
      builder: (_, __) => CartScreen(productsKey: _cartProductList),
    );
    // TODO: add change notifier
    final menuIngredientRow = OrderIngredientList();

    return Scaffold(
      // avoid resize when keyboard(bottom inset) shows
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            final result = await showCircularBottomSheet<OrderActionTypes>(
              context,
              actions: OrderActions.actions(),
            );
            await OrderActions.execAction(context, result);
          },
          icon: Icon(KIcons.more),
        ),
        actions: [
          AppbarTextButton(
            key: Key('order.action.order'),
            onPressed: () => _handleOrder(),
            child: Text('結帳'),
          ),
        ],
      ),
      body: FeatureProvider.instance.outlookOrder == OutlookOrder.sliding_panel
          ? OrderBySlidingPanel(
              key: _slidingPanel,
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
    // TODO: move to [Cart]
    OrderProvider.instance.ordered();
    super.didPop();
  }

  @override
  void didPopNext() {
    // Avoid popping actions, only close it when ordered.
    if (Cart.instance.isEmpty) {
      _slidingPanel.currentState?.reset();
    }
    super.didPopNext();
  }

  @override
  void didPush() {
    if (FeatureProvider.instance.awakeOrdering) {
      Wakelock.enable();
    }
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
    final result = await Navigator.of(context).pushNamed(route);

    if (result == true) {
      showSuccessSnackbar(context, tt('success'));
    }
  }
}
