import 'package:flutter/material.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
import 'package:possystem/ui/stock/replenishment/replenishment_screen.dart';
import 'package:provider/provider.dart';

import 'models/customer/customer_setting.dart';
import 'models/menu/catalog.dart';
import 'models/menu/product.dart';
import 'models/menu/product_ingredient.dart';
import 'models/menu/product_quantity.dart';
import 'models/stock/ingredient.dart';
import 'models/stock/quantity.dart';
import 'models/stock/replenishment.dart';
import 'ui/analysis/analysis_screen.dart';
import 'ui/cashier/cashier_screen.dart';
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
import 'ui/setting/setting_screen.dart';
import 'ui/stock/quantity/quantity_screen.dart';
import 'ui/stock/quantity/widgets/quantity_modal.dart';
import 'ui/stock/replenishment/replenishment_modal.dart';
import 'ui/stock/stock_screen.dart';
import 'ui/stock/widgets/ingredient_modal.dart';

class Routes {
  static const String analysis = 'analysis';
  static const String cashier = 'cashier';
  static const String customer = 'customer';
  static const String menu = 'menu';
  static const String order = 'order';
  static const String setting = 'setting';
  static const String stock = 'stock';

  // sub-route
  static const String cashierChanger = 'cashier/changer';
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
  static const String stockReplenishment = 'stock/replenishment';
  static const String stockReplenishmentModal = 'stock/replenishment/modal';
  static const String stockQuantity = 'stock/quantity';
  static const String stockIngredient = 'stock/ingredient';
  static const String stockQuantityModal = 'stock/quantity/modal';

  static final routes = <String, WidgetBuilder>{
    analysis: (_) => AnalysisScreen(),
    customer: (_) => CustomerScreen(),
    cashier: (_) => CashierScreen(),
    menu: (_) => MenuScreen(),
    order: (_) => OrderScreen(),
    setting: (_) => SettingScreen(),
    stock: (_) => StockScreen(),
    // sub-route
    // cashier
    cashierChanger: (context) => ChangerModal(),
    // customer
    customerModal: (context) =>
        CustomerModal(setting: arg<CustomerSetting?>(context)),
    customerReorder: (context) => CustomerOrderableList(),
    customerSettingOption: (context) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      return arg is CustomerSettingOption
          ? CustomerSettingOptionModal(
              option: arg,
              setting: arg.setting,
            )
          : CustomerSettingOptionModal(setting: arg as CustomerSetting);
    },
    customerSettingReorder: (context) =>
        CustomerSettingOrderableList(setting: arg<CustomerSetting>(context)),
    // menu
    menuSearch: (_) => MenuSearch(),
    menuCatalog: (context) => ChangeNotifierProvider.value(
          value: arg<Catalog>(context),
          builder: (_, __) => CatalogScreen(),
        ),
    menuCatalogModal: (context) =>
        CatalogModal(catalog: arg<Catalog?>(context)),
    menuCatalogReorder: (context) => CatalogOrderableList(),
    menuProduct: (context) => ChangeNotifierProvider.value(
          value: arg<Product>(context),
          builder: (_, __) => ProductScreen(),
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
    menuProductReorder: (context) =>
        ProductOrderableList(arg<Catalog>(context)),
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
    orderCustomer: (_) => OrderCustomerModal(),
    orderCalculator: (_) => OrderCashierModal(),
    // stock
    stockIngredient: (context) =>
        IngredientModal(ingredient: arg<Ingredient?>(context)),
    stockQuantity: (_) => QuantityScreen(),
    stockQuantityModal: (context) =>
        QuantityModal(quantity: arg<Quantity?>(context)),
    stockReplenishment: (context) => ReplenishmentScreen(),
    stockReplenishmentModal: (context) =>
        ReplenishmentModal(replenishment: arg<Replenishment?>(context)),
  };

  static T arg<T>(BuildContext context) =>
      ModalRoute.of(context)!.settings.arguments as T;
}
