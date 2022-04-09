import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/translator.dart';

enum GoogleSheetAble {
  menu,
  stock,
  quantities,
  replenisher,
  customer,
}

class GoogleSheetFormatter extends Formatter<GoogleSheetCellData> {
  final bool withHeader;

  const GoogleSheetFormatter({required this.withHeader});

  static Repository getTarget(GoogleSheetAble able) {
    switch (able) {
      case GoogleSheetAble.menu:
        return Menu.instance;
      case GoogleSheetAble.stock:
        return Stock.instance;
      case GoogleSheetAble.quantities:
        return Quantities.instance;
      case GoogleSheetAble.replenisher:
        return Replenisher.instance;
      case GoogleSheetAble.customer:
        return CustomerSettings.instance;
    }
  }

  @override
  List<GoogleSheetCellData> getHead(Repository target) {
    if (target is Menu) {
      return _getMenuHead(target);
    } else if (target is Stock) {
      return _getStockHead(target);
    } else if (target is Quantities) {
      return _getQuantitiesHead(target);
    } else if (target is Replenisher) {
      return _getReplenisherHead(target);
    } else if (target is CustomerSettings) {
      return _getCustomersHead(target);
    }

    return const [];
  }

  @override
  List<List<GoogleSheetCellData>> getItems(Repository target) {
    if (target is Menu) {
      return _getMenuItems(target);
    } else if (target is Stock) {
      return _getStockItems(target);
    } else if (target is Quantities) {
      return _getQuantitiesItems(target);
    } else if (target is Replenisher) {
      return _getReplenisherItems(target);
    } else if (target is CustomerSettings) {
      return _getCustomersItems(target);
    }

    return const [];
  }

  List<GoogleSheetCellData> _getMenuHead(Menu menu) {
    return <GoogleSheetCellData>[
      if (withHeader) _appUseHeader,
      _toCD(S.menuCatalogNameLabel),
      _toCD(S.menuProductNameLabel),
      _toCD(S.menuProductPriceLabel),
      _toCD(S.menuProductCostLabel),
      _toCD(S.exporterProductIngredientInfoTitle,
          S.exporterProductIngredientInfoNote),
    ];
  }

  List<List<GoogleSheetCellData>> _getMenuItems(Menu menu) {
    return <List<GoogleSheetCellData>>[
      for (final product in menu.products)
        [
          if (withHeader)
            GoogleSheetCellData(
              stringValue: product.googleSheetHeader,
              isDanger: true,
            ),
          GoogleSheetCellData(stringValue: product.catalog.name),
          GoogleSheetCellData(stringValue: product.name),
          GoogleSheetCellData(numberValue: product.price),
          GoogleSheetCellData(numberValue: product.cost),
          GoogleSheetCellData(stringValue: product.googleSheetIngredientInfo),
        ],
    ];
  }

  List<GoogleSheetCellData> _getStockHead(Stock stock) {
    return <GoogleSheetCellData>[
      if (withHeader) _appUseHeader,
      _toCD(S.stockIngredientNameLabel),
      _toCD(S.stockIngredientAmountLabel),
    ];
  }

  List<List<GoogleSheetCellData>> _getStockItems(Stock stock) {
    return <List<GoogleSheetCellData>>[
      for (final ingredient in stock.itemList)
        [
          if (withHeader) GoogleSheetCellData(stringValue: ingredient.id),
          GoogleSheetCellData(stringValue: ingredient.name),
          ingredient.currentAmount == null
              ? GoogleSheetCellData(stringValue: '')
              : GoogleSheetCellData(numberValue: ingredient.currentAmount),
        ],
    ];
  }

  List<GoogleSheetCellData> _getQuantitiesHead(Quantities quantities) {
    return <GoogleSheetCellData>[
      if (withHeader) _appUseHeader,
      _toCD(S.stockQuantityNameLabel),
      _toCD(S.stockQuantityProportionLabel, S.stockQuantityProportionHelper),
    ];
  }

  List<List<GoogleSheetCellData>> _getQuantitiesItems(Quantities quantities) {
    return <List<GoogleSheetCellData>>[
      for (final quantity in quantities.itemList)
        [
          if (withHeader) GoogleSheetCellData(stringValue: quantity.id),
          GoogleSheetCellData(stringValue: quantity.name),
          GoogleSheetCellData(numberValue: quantity.defaultProportion),
        ],
    ];
  }

  List<GoogleSheetCellData> _getReplenisherHead(Replenisher replenisher) {
    return <GoogleSheetCellData>[
      if (withHeader) _appUseHeader,
      _toCD(S.stockReplenishmentNameLabel),
      _toCD(S.exporterReplenishmentTitle, S.exporterReplenishmentNote)
    ];
  }

  List<List<GoogleSheetCellData>> _getReplenisherItems(
      Replenisher replenisher) {
    return <List<GoogleSheetCellData>>[
      for (final repl in replenisher.itemList)
        [
          if (withHeader)
            GoogleSheetCellData(stringValue: repl.googleSheetHeader),
          GoogleSheetCellData(stringValue: repl.name),
          GoogleSheetCellData(stringValue: repl.googleSheetDataInfo),
        ],
    ];
  }

  List<GoogleSheetCellData> _getCustomersHead(CustomerSettings cs) {
    return <GoogleSheetCellData>[
      if (withHeader) _appUseHeader,
      _toCD(S.customerSettingNameLabel),
      _toCD(S.customerSettingModeTitle, S.exporterCustomerSettingModeNote),
      _toCD(S.exporterCustomerSettingOptionTitle,
          S.exporterCustomerSettingOptionNote),
    ];
  }

  List<List<GoogleSheetCellData>> _getCustomersItems(CustomerSettings cs) {
    return <List<GoogleSheetCellData>>[
      for (final setting in cs.itemList)
        [
          if (withHeader)
            GoogleSheetCellData(stringValue: setting.googleSheetHeader),
          GoogleSheetCellData(stringValue: setting.name),
          GoogleSheetCellData(
              stringValue: S.customerSettingModeNames(setting.mode)),
          GoogleSheetCellData(stringValue: setting.googleSheetDataInfo),
        ],
    ];
  }
}

extension GoogleSheetProductFormatter on Product {
  String get googleSheetHeader {
    final info = [
      for (var ingredient in items)
        ',${ingredient.id},${ingredient.ingredient.id},${ingredient.length}' +
            [
              for (var quantity in ingredient.items)
                ',${quantity.id},${quantity.quantity.id}'
            ].join('')
    ].join('');

    return '${catalog.id},$id,$length$info';
  }

  String get googleSheetIngredientInfo => [
        for (var ingredient in items)
          '- ${ingredient.name},${ingredient.amount}' +
              ingredient.itemList
                  .map((quantity) => <String>[
                        '\n  + ${quantity.name}',
                        quantity.amount.toString(),
                        quantity.additionalPrice.toString(),
                        quantity.additionalCost.toString(),
                      ].join(','))
                  .join('')
      ].join('\n');
}

extension GoogleSheetReplenishmentFormatter on Replenishment {
  String get googleSheetHeader => [
        id,
        ...ingredientData.keys.map(
          (e) => e.id,
        )
      ].join(',');

  String get googleSheetDataInfo => [
        for (final entry in ingredientData.entries)
          '- ${entry.key.name},${entry.value}',
      ].join('\n');
}

extension GoogleSheetCustomerSettingFormatter on CustomerSetting {
  String get googleSheetHeader => [
        id,
        ...itemList.map(
          (e) => e.id,
        )
      ].join(',');

  String get googleSheetDataInfo => [
        for (final item in itemList)
          '- ${item.name},${item.isDefault},${item.modeValue}',
      ].join('\n');
}

GoogleSheetCellData _toCD(String title, [String? note]) {
  return GoogleSheetCellData(
    stringValue: title,
    note: note,
    isBold: true,
  );
}

final _appUseHeader = GoogleSheetCellData(
  stringValue: S.exporterGSFirstColumnTitle,
  note: S.exporterGSFirstColumnNote,
  isDanger: true,
);
