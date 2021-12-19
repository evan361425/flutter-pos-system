import 'package:flutter/material.dart';
import 'package:possystem/ui/cashier/widgets/cashier_surplus.dart';
import 'package:possystem/ui/home/home_setup_feature_request.dart';
import 'package:provider/provider.dart';
import 'package:simple_tip/simple_tip.dart';

import 'models/customer/customer_setting.dart';
import 'models/customer/customer_setting_option.dart';
import 'models/menu/catalog.dart';
import 'models/menu/product.dart';
import 'models/menu/product_ingredient.dart';
import 'models/menu/product_quantity.dart';
import 'models/stock/ingredient.dart';
import 'models/stock/quantity.dart';
import 'models/stock/replenishment.dart';
import 'ui/cashier/changer/changer_modal.dart';
import 'ui/customer/customer_screen.dart';
import 'ui/customer/widgets/customer_orderable_list.dart';
import 'ui/customer/widgets/customer_setting_modal.dart';
import 'ui/customer/widgets/customer_setting_option_modal.dart';
import 'ui/customer/widgets/customer_setting_orderable_list.dart';
import 'ui/menu/catalog/catalog_screen.dart';
import 'ui/menu/catalog/widgets/product_modal.dart';
import 'ui/menu/catalog/widgets/product_orderable_list.dart';
import 'ui/menu/menu_screen.dart';
import 'ui/menu/menu_search.dart';
import 'ui/menu/product/product_screen.dart';
import 'ui/menu/product/widgets/product_ingredient_modal.dart';
import 'ui/menu/product/widgets/product_quantity_modal.dart';
import 'ui/menu/widgets/catalog_modal.dart';
import 'ui/menu/widgets/catalog_orderable_list.dart';
import 'ui/order/cashier/order_cashier_modal.dart';
import 'ui/order/cashier/order_customer_modal.dart';
import 'ui/order/order_screen.dart';
import 'ui/quantities/quantity_screen.dart';
import 'ui/quantities/widgets/quantity_modal.dart';
import 'ui/setting/setting_screen.dart';
import 'ui/stock/replenishment/replenishment_modal.dart';
import 'ui/stock/replenishment/replenishment_screen.dart';
import 'ui/stock/widgets/ingredient_modal.dart';

class Routes {
  static const String customer = 'customer';
  static const String featureRequest = 'feature_request';
  static const String menu = 'menu';
  static const String order = 'order';
  static const String quantities = 'quantities';
  static const String setting = 'setting';

  // sub-route
  static const String cashierChanger = 'cashier/changer';
  static const String cashierSurplus = 'cashier/surplus';
  static const String customerModal = 'customer/modal';
  static const String customerReorder = 'customer/reorder';
  static const String customerSetting = 'customer/setting';
  static const String customerSettingOption = 'customer/setting/option';
  static const String customerSettingReorder = 'customer/setting/reorder';
  static const String menuSearch = 'menu/search';
  static const String menuCatalog = 'menu/catalog';
  static const String menuCatalogModal = 'menu/catalog/modal';
  static const String menuCatalogReorder = 'menu/catalog/reorder';
  static const String menuProduct = 'menu/product';
  static const String menuProductModal = 'menu/product/modal';
  static const String menuProductReorder = 'menu/product/reorder';
  static const String menuIngredient = 'menu/ingredient';
  static const String menuQuantity = 'menu/quantity';
  static const String orderCustomer = 'order/customer';
  static const String orderCalculator = 'order/calculator';
  static const String quantityModal = 'quantities/modal';
  static const String stockReplenishment = 'stock/replenishment';
  static const String stockReplenishmentModal = 'stock/replenishment/modal';
  static const String stockIngredient = 'stock/ingredient';

  static late final RouteObserver<ModalRoute<void>> routeObserver;

  static final routes = <String, WidgetBuilder>{
    customer: (_) => CustomerScreen(
          routeObserver: routeObserver,
          tipGrouper: GlobalKey<TipGrouperState>(),
        ),
    featureRequest: (_) => const HomeSetupFeatureRequestScreen(),
    menu: (_) => MenuScreen(
          routeObserver: routeObserver,
          tipGrouper: GlobalKey<TipGrouperState>(),
        ),
    order: (_) => OrderScreen(
          routeObserver: routeObserver,
          tipGrouper: GlobalKey<TipGrouperState>(),
        ),
    setting: (_) => const SettingScreen(),
    // sub-route
    // cashier
    cashierChanger: (_) => const ChangerModal(),
    cashierSurplus: (_) => CashierSurplus(),
    // customer
    customerModal: (ctx) => CustomerModal(setting: _a<CustomerSetting?>(ctx)),
    customerReorder: (_) => const CustomerOrderableList(),
    customerSettingOption: (context) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      return arg is CustomerSettingOption
          ? CustomerSettingOptionModal(
              option: arg,
              setting: arg.setting,
            )
          : CustomerSettingOptionModal(setting: arg as CustomerSetting);
    },
    customerSettingReorder: (ctx) =>
        CustomerSettingOrderableList(setting: _a<CustomerSetting>(ctx)),
    // menu
    menuSearch: (_) => const MenuSearch(),
    menuCatalog: (context) => ChangeNotifierProvider.value(
          value: _a<Catalog>(context),
          builder: (_, __) => const CatalogScreen(),
        ),
    menuCatalogModal: (context) => CatalogModal(catalog: _a<Catalog?>(context)),
    menuCatalogReorder: (context) => const CatalogOrderableList(),
    menuProduct: (context) => ChangeNotifierProvider.value(
          value: _a<Product>(context),
          builder: (_, __) => const ProductScreen(),
        ),
    menuProductModal: (context) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      return arg is Product
          ? ProductModal(
              product: arg,
              catalog: arg.catalog,
            )
          : ProductModal(catalog: arg as Catalog);
    },
    menuProductReorder: (ctx) => ProductOrderableList(_a<Catalog>(ctx)),
    menuIngredient: (context) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      return arg is ProductIngredient
          ? ProductIngredientModal(
              ingredient: arg,
              product: arg.product,
            )
          : ProductIngredientModal(product: arg as Product);
    },
    menuQuantity: (context) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      return arg is ProductQuantity
          ? ProductQuantityModal(
              quantity: arg,
              ingredient: arg.ingredient,
            )
          : ProductQuantityModal(ingredient: arg as ProductIngredient);
    },
    // order
    orderCustomer: (_) => const OrderCustomerModal(),
    orderCalculator: (_) => OrderCashierModal(),
    // quantities
    quantities: (_) => const QuantityScreen(),
    quantityModal: (ctx) => QuantityModal(_a<Quantity?>(ctx)),
    // stock
    stockIngredient: (ctx) => IngredientModal(ingredient: _a<Ingredient?>(ctx)),
    stockReplenishment: (_) => const ReplenishmentScreen(),
    stockReplenishmentModal: (ctx) =>
        ReplenishmentModal(_a<Replenishment?>(ctx)),
  };

  static T _a<T>(BuildContext context) =>
      ModalRoute.of(context)!.settings.arguments as T;
}
