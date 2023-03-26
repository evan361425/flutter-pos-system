import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/menu/catalog.dart';
import 'models/menu/product.dart';
import 'models/menu/product_ingredient.dart';
import 'models/menu/product_quantity.dart';
import 'models/order/order_attribute.dart';
import 'models/order/order_attribute_option.dart';
import 'models/stock/ingredient.dart';
import 'models/stock/quantity.dart';
import 'models/stock/replenishment.dart';
import 'ui/cashier/changer/changer_modal.dart';
import 'ui/cashier/widgets/cashier_surplus.dart';
import 'ui/exporter/exporter_screen.dart';
import 'ui/home/home_setup_feature_request.dart';
import 'ui/image_gallery_screen.dart';
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
import 'ui/order/cashier/order_details_screen.dart';
import 'ui/order/order_screen.dart';
import 'ui/order_attr/order_attribute_screen.dart';
import 'ui/order_attr/widgets/order_attribute_modal.dart';
import 'ui/order_attr/widgets/order_attribute_option_modal.dart';
import 'ui/order_attr/widgets/order_attribute_option_reorder.dart';
import 'ui/order_attr/widgets/order_attribute_reorder.dart';
import 'ui/quantities/quantity_screen.dart';
import 'ui/quantities/widgets/quantity_modal.dart';
import 'ui/setting/setting_screen.dart';
import 'ui/stock/replenishment/replenishment_modal.dart';
import 'ui/stock/replenishment/replenishment_screen.dart';
import 'ui/stock/widgets/ingredient_modal.dart';

class Routes {
  static const String orderAttr = 'order_attr';
  static const String exporter = 'exporter';
  static const String featureRequest = 'feature_request';
  static const String menu = 'menu';
  static const String order = 'order';
  static const String quantities = 'quantities';
  static const String setting = 'setting';
  static const String imageGallery = 'image_gallery';

  // sub-route
  static const String cashierChanger = 'cashier/changer';
  static const String cashierSurplus = 'cashier/surplus';
  static const String orderAttrModal = 'order_attr/modal';
  static const String orderAttrReorder = 'order_attr/reorder';
  static const String orderAttrOption = 'order_attr/option';
  static const String orderAttrOptionReorder = 'order_attr/option/reorder';
  static const String menuSearch = 'menu/search';
  static const String menuCatalog = 'menu/catalog';
  static const String menuCatalogModal = 'menu/catalog/modal';
  static const String menuCatalogReorder = 'menu/catalog/reorder';
  static const String menuProduct = 'menu/product';
  static const String menuProductModal = 'menu/product/modal';
  static const String menuProductReorder = 'menu/product/reorder';
  static const String menuIngredient = 'menu/ingredient';
  static const String menuQuantity = 'menu/quantity';
  static const String orderDetails = 'order/details';
  static const String quantityModal = 'quantities/modal';
  static const String stockReplenishment = 'stock/replenishment';
  static const String stockReplenishmentModal = 'stock/replenishment/modal';
  static const String stockIngredient = 'stock/ingredient';

  static final routes = <String, WidgetBuilder>{
    orderAttr: (_) => const OrderAttributeScreen(),
    featureRequest: (_) => const HomeSetupFeatureRequestScreen(),
    menu: (_) => const MenuScreen(),
    order: (_) => const OrderScreen(),
    setting: (_) => const SettingScreen(),
    imageGallery: (_) => const ImageGalleryScreen(),
    // sub-route
    // cashier
    cashierChanger: (_) => const ChangerModal(),
    cashierSurplus: (_) => const CashierSurplus(),
    // order_attribute
    orderAttrModal: (ctx) =>
        OrderAttributeModal(attribute: _a<OrderAttribute?>(ctx)),
    orderAttrReorder: (_) => const OrderAttributeReorder(),
    orderAttrOption: (context) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      return arg is OrderAttributeOption
          ? OrderAttributeOptionModal(
              option: arg,
              attribute: arg.attribute,
            )
          : OrderAttributeOptionModal(attribute: arg as OrderAttribute);
    },
    orderAttrOptionReorder: (ctx) =>
        OrderAttributeOptionReorder(attribute: _a<OrderAttribute>(ctx)),
    exporter: (_) => const ExporterScreen(),
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
    orderDetails: (_) => const OrderDetailsScreen(),
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
