import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/translator.dart';

extension GoogleSheetMenuFormatter on Menu {
  List<List<GoogleSheetCellData>> getGoogleSheetItems({
    bool withHeader = false,
  }) {
    return <List<GoogleSheetCellData>>[
      for (final product in products)
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

  List<GoogleSheetCellData> getGoogleSheetHeader({
    bool withHeader = false,
  }) {
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

extension GoogleSheetStockFormatter on Stock {
  List<List<GoogleSheetCellData>> getGoogleSheetItems({
    bool withHeader = false,
  }) {
    return <List<GoogleSheetCellData>>[
      for (final ingredient in items)
        [
          if (withHeader) GoogleSheetCellData(stringValue: ingredient.id),
          GoogleSheetCellData(stringValue: ingredient.name),
          ingredient.currentAmount == null
              ? GoogleSheetCellData(stringValue: '')
              : GoogleSheetCellData(numberValue: ingredient.currentAmount),
        ],
    ];
  }

  List<GoogleSheetCellData> getGoogleSheetHeader({
    bool withHeader = false,
  }) {
    return <GoogleSheetCellData>[
      if (withHeader) _appUseHeader,
      _toCD(S.stockIngredientNameLabel),
      _toCD(S.stockIngredientAmountLabel),
    ];
  }
}

extension GoogleSheetQuantitiesFormatter on Quantities {
  List<List<GoogleSheetCellData>> getGoogleSheetItems({
    bool withHeader = false,
  }) {
    return <List<GoogleSheetCellData>>[
      for (final quantity in items)
        [
          if (withHeader) GoogleSheetCellData(stringValue: quantity.id),
          GoogleSheetCellData(stringValue: quantity.name),
          GoogleSheetCellData(numberValue: quantity.defaultProportion),
        ],
    ];
  }

  List<GoogleSheetCellData> getGoogleSheetHeader({
    bool withHeader = false,
  }) {
    return <GoogleSheetCellData>[
      if (withHeader) _appUseHeader,
      _toCD(S.stockQuantityNameLabel),
      _toCD(S.stockQuantityProportionLabel, S.stockQuantityProportionHelper),
    ];
  }
}

extension GoogleSheetReplenisherFormatter on Replenisher {
  List<List<GoogleSheetCellData>> getGoogleSheetItems({
    bool withHeader = false,
  }) {
    return <List<GoogleSheetCellData>>[
      for (final repl in items)
        [
          if (withHeader)
            GoogleSheetCellData(stringValue: repl.googleSheetHeader),
          GoogleSheetCellData(stringValue: repl.name),
          GoogleSheetCellData(stringValue: repl.googleSheetDataInfo),
        ],
    ];
  }

  List<GoogleSheetCellData> getGoogleSheetHeader({
    bool withHeader = false,
  }) {
    return <GoogleSheetCellData>[
      if (withHeader) _appUseHeader,
      _toCD(S.stockReplenishmentNameLabel),
      _toCD(S.exporterReplenishmentTitle, S.exporterReplenishmentNote)
    ];
  }
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

extension GoogleSheetCustomerSettingsFormatter on CustomerSettings {
  List<List<GoogleSheetCellData>> getGoogleSheetItems({
    bool withHeader = false,
  }) {
    return <List<GoogleSheetCellData>>[
      for (final setting in itemList)
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

  List<GoogleSheetCellData> getGoogleSheetHeader({
    bool withHeader = false,
  }) {
    return <GoogleSheetCellData>[
      if (withHeader) _appUseHeader,
      _toCD(S.customerSettingNameLabel),
      _toCD(S.customerSettingModeTitle, S.exporterCustomerSettingModeNote),
      _toCD(S.exporterCustomerSettingOptionTitle,
          S.exporterCustomerSettingOptionNote),
    ];
  }
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
