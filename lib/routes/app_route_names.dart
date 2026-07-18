import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Centralized route names for the entire application (Law 4.2 of
/// `.cursorrules` — zero magic strings for navigation).
///
/// The string values MUST stay in sync with the `name:` attribute of every
/// `GoRoute` declared in `lib/routes.dart`. When you add or rename a route,
/// add / rename its constant here first and use it from the UI via
/// `context.pushNamed(AppRouteNames.<xxx>, ...)`.
///
/// Path helpers (for `context.go(...)` / `PopButton.safePop(path: ...)`)
/// are grouped at the bottom.
class AppRouteNames {
  const AppRouteNames._();

  // ----- Base -----------------------------------------------------------
  static const String base = '/pos';

  /// Full URL builder for external sharing (email, deep-link, README...).
  static String url(String routeName) =>
      'https://evan361425.github.io$base/$routeName';

  /// Full local path for `context.go(...)`.
  static String path(String routeName) => '$base/$routeName';

  /// Serialize a [DateTimeRange] for route query parameters (e.g. history → transit).
  static String serializeRange(DateTimeRange range) {
    final f = DateFormat('y-M-d');
    return '${f.format(range.start)}-${f.format(range.end)}';
  }

  // ----- Shell branches / top-level tabs --------------------------------
  static const String others = 'others';
  static const String homeMore = '$base/_';
  static const String homeAnalysis = '$base/anal';
  static const String homeStock = '$base/stock';
  static const String homeCashier = '$base/cashier';
  static const String homeFloorPlan = '$base/tables';

  // ----- Analysis -------------------------------------------------------
  static const String anal = 'anal';
  static const String chartCreate = 'chart.create';
  static const String chartUpdate = 'chart.update';
  static const String chartReorder = 'chart.reorder';

  // ----- Menu -----------------------------------------------------------
  static const String menu = 'menu';
  static const String menuCatalogCreate = 'menu.catalog.create';
  static const String menuCatalogUpdate = 'menu.catalog.update';
  static const String menuCatalogReorder = 'menu.catalog.reorder';
  static const String menuProduct = 'menu.product';
  static const String menuProductUpdate = 'menu.product.update';
  static const String menuProductReorder = 'menu.product.reorder';
  static const String menuProductUpdateIngredient =
      'menu.product.update.ingredient';
  static const String menuProductReorderIngredient =
      'menu.product.reorder.ingredient';

  // ----- Stock ----------------------------------------------------------
  static const String stock = 'stock';
  static const String stockIngrCreate = 'stock.ingr.create';
  static const String stockIngrUpdate = 'stock.ingr.update';
  static const String stockIngrRestock = 'stock.ingr.restock';
  static const String stockRepl = 'stock.repl';
  static const String stockReplCreate = 'stock.repl.create';
  static const String stockReplUpdate = 'stock.repl.update';
  static const String stockReplPreview = 'stock.repl.preview';

  // ----- Quantities -----------------------------------------------------
  static const String quantities = 'quantity';
  static const String quantityCreate = 'quantity.create';
  static const String quantityUpdate = 'quantity.update';

  // ----- Order Attributes ----------------------------------------------
  static const String orderAttr = 'oa';
  static const String orderAttrCreate = 'oa.create';
  static const String orderAttrUpdate = 'oa.update';
  static const String orderAttrReorder = 'oa.reorder';
  static const String orderAttrReorderOption = 'oa.reorder.option';

  // ----- Cashier --------------------------------------------------------
  static const String cashier = 'cashier';
  static const String cashierChanger = 'cashier.changer';
  static const String cashierSurplus = 'cashier.surplus';

  // ----- Order / Checkout ----------------------------------------------
  static const String order = 'order';
  static const String orderCheckout = 'order.checkout';
  static const String orderSplitBill = 'order.splitBill';

  // ----- Tables / Floor Plan -------------------------------------------
  static const String floorPlan = 'tables';

  // ----- Staff / Lock --------------------------------------------------
  static const String lock = 'lock';

  // ----- History --------------------------------------------------------
  static const String history = 'history';
  static const String historyOrder = 'history.order';

  // ----- Printer --------------------------------------------------------
  static const String printer = 'printer';
  static const String printerCreate = 'printer.create';
  static const String printerSettings = 'printer.settings';
  static const String printerUpdate = 'printer.update';

  // ----- Transit --------------------------------------------------------
  static const String transit = 'transit';
  static const String transitStation = 'transit.station';

  // ----- Miscellaneous entries -----------------------------------------
  static const String elf = 'elf';
  static const String imageGallery = 'imageGallery';
  static const String debug = 'debug';

  // ----- Settings -------------------------------------------------------
  static const String settings = 'settings';
  static const String settingsFeature = 'settings.feature';
  static const String settingsPrinterManagement = 'settings.printerManagement';
  static const String settingsStaff = 'settings.staff';
  static const String settingsCloudSync = 'settings.cloudSync';
  static const String managerDashboard = 'anal.dashboard';
  static const String closeRegister = 'shift.close';

  // -----------------------------------------------------------------------
  // Backwards-compatibility aliases (do NOT use in new code — kept only so
  // the WIP `lib/routes/*_routes.dart` scaffolding still compiles while the
  // migration to the dot-notation names above is in flight).
  // -----------------------------------------------------------------------
  static const String analytics = anal;
  static const String analyticsChartCreate = chartCreate;
  static const String analyticsChartUpdate = chartUpdate;
  static const String analyticsChartReorder = chartReorder;
  static const String stockIngredientCreate = stockIngrCreate;
  static const String stockIngredientUpdate = stockIngrUpdate;
  static const String stockIngredientRestock = stockIngrRestock;
  static const String stockReplenishment = stockRepl;
  static const String stockReplenishmentCreate = stockReplCreate;
  static const String stockReplenishmentUpdate = stockReplUpdate;
  static const String stockReplenishmentPreview = stockReplPreview;
  static const String stockQuantities = quantities;
  static const String stockQuantityCreate = quantityCreate;
  static const String stockQuantityUpdate = quantityUpdate;
  static const String orderAttributes = orderAttr;
  static const String orderAttributeCreate = orderAttrCreate;
  static const String orderAttributeUpdate = orderAttrUpdate;
  static const String orderAttributeReorder = orderAttrReorder;
  static const String orderAttributeOptionReorder = orderAttrReorderOption;
  static const String orderAttributeUpdateOption = 'oa.update.option';
  static const String menuProductIngredientUpdate = menuProductUpdateIngredient;
  static const String menuProductIngredientReorder =
      menuProductReorderIngredient;
  static const String menuProductUpdateQuantity =
      'menu.product.update.quantity';
}

/// Layout mode of the home shell (bottom bar / drawer / rail).
enum HomeMode {
  bottomNavigationBar,
  drawer,
  rail;

  bool isMobile() => this == HomeMode.bottomNavigationBar;
}

/// Backwards-compatible top-level alias used by older call sites.
String serializeRange(DateTimeRange range) =>
    AppRouteNames.serializeRange(range);
