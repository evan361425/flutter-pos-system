import 'package:flutter/material.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/style/appbar_text_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/my_app.dart';
import 'package:possystem/providers/feature_provider.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cart/cart_metadata.dart';
import 'package:possystem/ui/order/cashier/calculator_dialog.dart';
import 'package:possystem/ui/order/widgets/order_actions.dart';
import 'package:possystem/ui/order/widgets/order_ingredient_list.dart';
import 'package:possystem/ui/order/widgets/order_product_list.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';

import 'cart/cart_product_list.dart';
import 'cart/cart_screen.dart';
import 'widgets/order_catalog_list.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with RouteAware {
  final _orderProductList = GlobalKey<OrderProductListState>();
  final _cartProductList = GlobalKey<CartProductListState>();

  @override
  Widget build(BuildContext context) {
    final menu = context.read<Menu>();

    // get in order
    final catalogs = menu.itemList.where((e) => e.isNotEmpty).toList();

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
    final orderingProductRow = Card(
      child: ChangeNotifierProvider.value(
        value: Cart.instance,
        builder: (_, __) => CartScreen(productsKey: _cartProductList),
      ),
    );
    final menuIngredientRow = OrderIngredientList();
    final collapsed = ChangeNotifierProvider.value(
      value: Cart.instance,
      builder: (_, __) => CartMetadata(isVertical: true),
    );

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyText1?.color ?? theme.primaryColor;

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
            onPressed: () => _handleOrder(),
            child: Text(tt('order.action.order')),
          ),
        ],
      ),
      body: SlidingUpPanel(
        backdropEnabled: true,
        color: Colors.transparent,
        minHeight: 64.0,
        panel: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
                onTap: () => debugPrint('hi'), child: Container(height: 64.0)),
            Expanded(child: orderingProductRow),
            menuIngredientRow,
          ],
        ),
        boxShadow: [],
        collapsed: Column(children: [
          Center(
            child: Container(
              height: 8.0,
              width: 32.0,
              decoration: BoxDecoration(
                color: textColor.withAlpha(196),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: textColor),
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: collapsed,
            ),
          ),
        ]),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          menuCatalogRow,
          Expanded(child: menuProductRow),
        ]),
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
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CalculatorDialog(),
    );

    if (result == true) {
      showSuccessSnackbar(context, tt('success'));
    }
  }
}
