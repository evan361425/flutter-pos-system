import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/linkify.dart';
import 'package:possystem/components/style/buttons.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/helpers/breakpoint.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/settings/checkout_warning.dart';
import 'package:possystem/settings/order_awakening_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cart/cart_metadata_view.dart';
import 'package:possystem/ui/order/cart/cart_product_list.dart';
import 'package:possystem/ui/order/cart/cart_product_selector.dart';
import 'package:possystem/ui/order/widgets/printer_button_view.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'cart/cart_product_state_selector.dart';
import 'widgets/draggable_sheet_view.dart';
import 'widgets/order_catalog_list_view.dart';
import 'widgets/order_product_list_view.dart';
import 'widgets/orientated_view.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late final PageController _pageController;

  /// Change the catalog index and pass to [OrderProductListView] and [OrderCatalogListView]
  late final ValueNotifier<int> _catalogIndexNotifier;

  /// Used to update the view of [OrderProductListView]
  late final ValueNotifier<ProductListView> _productViewNotifier;

  /// Reset panel to initial state, used by [DraggableSheetView]
  final _Notifier _resetNotifier = _Notifier();

  @override
  Widget build(BuildContext context) {
    final catalogs = Menu.instance.notEmptyItems;

    final orderCatalogListView = OrderCatalogListView(
      catalogs: catalogs,
      indexNotifier: _catalogIndexNotifier,
      viewNotifier: _productViewNotifier,
      onSelected: (index) => _pageController.jumpToPage(index),
    );
    final orderProductListView = ListenableBuilder(
      listenable: _productViewNotifier,
      builder: (context, _) => PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => _catalogIndexNotifier.value = index,
        itemCount: catalogs.length,
        itemBuilder: (context, index) => OrderProductListView(
          products: catalogs[index].itemList,
          view: _productViewNotifier.value,
        ),
      ),
    );

    final body = Breakpoint.find(width: MediaQuery.sizeOf(context).width) <= Breakpoint.medium
        ? DraggableSheetView(
            row1: orderCatalogListView,
            row2: orderProductListView,
            row3_1: const CartProductSelector(),
            row3_2Builder: (scroll, scrollable) => Expanded(
              child: CartProductList(
                scrollController: scroll,
                scrollable: scrollable,
              ),
            ),
            row3_3: const CartMetadataView(),
            row4: const CartProductStateSelector(),
            resetNotifier: _resetNotifier,
          )
        : OrientatedView(
            row1: orderCatalogListView,
            row2: orderProductListView,
            row3_1: const CartProductSelector(),
            row3_2: const Expanded(child: CartProductList()),
            row3_3: const CartMetadataView(),
            row4: const CartProductStateSelector(),
          );

    return TutorialWrapper(
      child: Scaffold(
        // avoid resize when keyboard(bottom inset) shows
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: const PopButton(),
          actions: [
            MoreButton(key: const Key('order.more'), onPressed: _showActions),
            const PrinterButtonView(),
            TextButton(
              key: const Key('order.checkout'),
              onPressed: () => _handleCheckout(),
              child: Text(S.orderActionCheckout),
            ),
          ],
        ),
        body: body,
      ),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _pageController.dispose();
    _catalogIndexNotifier.dispose();
    _productViewNotifier.dispose();
    _resetNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WakelockPlus.toggle(enable: OrderAwakeningSetting.instance.value);
    // rebind menu/attributes if changed
    Cart.instance.rebind();

    _pageController = PageController();
    _catalogIndexNotifier = ValueNotifier<int>(0);
    _productViewNotifier = ValueNotifier<ProductListView>(ProductListView.grid);
    super.initState();
  }

  void _handleCheckout() async {
    final status = await context.pushNamed<CheckoutStatus>(Routes.orderCheckout);
    if (status != null && mounted) {
      handleCheckoutStatus(context, status);
      _resetNotifier.notify();
    }
  }

  void _showActions(BuildContext context) async {
    final result = await showCircularBottomSheet<_Action>(
      context,
      actions: [
        BottomSheetAction(
          key: const Key('order.action.exchange'),
          title: Text(S.orderActionExchange),
          leading: const Icon(Icons.change_circle_outlined),
          returnValue: const _Action(route: Routes.cashierChanger),
        ),
        BottomSheetAction(
          key: const Key('order.action.stash'),
          title: Text(S.orderActionStash),
          leading: const Icon(Icons.archive_outlined),
          returnValue: _Action(action: _handleStash),
        ),
        BottomSheetAction(
          key: const Key('order.action.history'),
          title: Text(S.orderActionReview),
          leading: const Icon(Icons.history_outlined),
          returnValue: const _Action(route: Routes.history),
        ),
      ],
    );

    if (context.mounted && result != null) {
      final success = await result.exec(context);

      if (success == true && context.mounted) {
        showSnackBar(S.actSuccess, context: context);
      }
    }
  }

  Future<bool?> _handleStash() {
    DraggableScrollableActuator.reset(context);
    return Cart.instance.stash();
  }
}

void handleCheckoutStatus(BuildContext context, CheckoutStatus status) {
  status = CheckoutWarningSetting.instance.shouldShow(status);

  switch (status) {
    case CheckoutStatus.ok:
    case CheckoutStatus.stash:
    case CheckoutStatus.restore:
      showSnackBar(S.actSuccess, context: context);
      break;
    case CheckoutStatus.cashierNotEnough:
      showSnackBar(S.orderSnackbarCashierNotEnough, context: context);
      break;
    case CheckoutStatus.cashierUsingSmall:
      showMoreInfoSnackBar(
        S.orderSnackbarCashierUsingSmallMoney,
        Linkify.fromString(S.orderSnackbarCashierUsingSmallMoneyHelper(Routes.getRoute('settings/checkoutWarning'))),
        context: context,
      );
      break;
    default:
  }
}

/// [DraggableScrollableActuator] will trigger `animateTo` while building widget
/// which will cause `setState` to be called during build.
///
/// This notifier is used to avoid this issue.
class _Notifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

class _Action {
  final Future<bool?> Function()? action;

  final String? route;

  const _Action({this.action, this.route});

  Future<bool?> exec(BuildContext context) {
    return route == null ? action!() : context.pushNamed(route!);
  }
}

enum ProductListView {
  grid(Icon(Icons.grid_view_outlined)),
  list(Icon(Icons.view_list_outlined));

  final Icon icon;

  const ProductListView(this.icon);
}
