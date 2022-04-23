import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/customer_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
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
  const GoogleSheetFormatter();

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
  List<FormattedItem> format(Repository target, List<List<Object?>> rows) {
    final List<FormattedItem> result = [];
    var index = 1;
    for (var row in rows) {
      final msg = _validate(target, row);
      if (msg == null) {
        result.add(FormattedItem(item: _format(target, row)));
      } else {
        result.add(FormattedItem(error: FormatterValidateError(msg, index)));
      }
      index++;
    }

    return result;
  }

  @override
  List<GoogleSheetCellData> getHead(Repository target) {
    if (target is Menu) {
      return target._getGoogleSheetHead();
    } else if (target is Stock) {
      return target._getGoogleSheetHead();
    } else if (target is Quantities) {
      return target._getGoogleSheetHead();
    } else if (target is Replenisher) {
      return target._getGoogleSheetHead();
    } else if (target is CustomerSettings) {
      return target._getGoogleSheetHead();
    }

    return const [];
  }

  @override
  List<List<GoogleSheetCellData>> getItems(Repository target) {
    if (target is Menu) {
      return target._getGoogleSheetItems();
    } else if (target is Stock) {
      return target._getGoogleSheetItems();
    } else if (target is Quantities) {
      return target._getGoogleSheetItems();
    } else if (target is Replenisher) {
      return target._getGoogleSheetItems();
    } else if (target is CustomerSettings) {
      return target._getGoogleSheetItems();
    }

    return const [];
  }

  String? _validate(Repository target, List<Object?> row) {
    if (target is Menu) {
      return target._validateGoogleSheetData(row);
    } else if (target is Stock) {
      return target._validateGoogleSheetData(row);
    } else if (target is Quantities) {
      return target._validateGoogleSheetData(row);
    } else if (target is Replenisher) {
      return target._validateGoogleSheetData(row);
    } else if (target is CustomerSettings) {
      return target._validateGoogleSheetData(row);
    }

    return null;
  }

  Model? _format(Repository target, List<Object?> row) {
    if (target is Menu) {
      return target._formatValidGoogleSheetData(row);
    } else if (target is Stock) {
      return target._formatValidGoogleSheetData(row);
    } else if (target is Quantities) {
      return target._formatValidGoogleSheetData(row);
    } else if (target is Replenisher) {
      return target._formatValidGoogleSheetData(row);
    } else if (target is CustomerSettings) {
      return target._formatValidGoogleSheetData(row);
    }

    return null;
  }
}

extension GoogleSheetMenuFormatter on Menu {
  List<GoogleSheetCellData> _getGoogleSheetHead() {
    return <GoogleSheetCellData>[
      _toCD(S.menuCatalogNameLabel),
      _toCD(S.menuProductNameLabel),
      _toCD(S.menuProductPriceLabel),
      _toCD(S.menuProductCostLabel),
      _toCD(S.exporterProductIngredientInfoTitle,
          S.exporterGSProductIngredientInfoNote),
    ];
  }

  List<List<GoogleSheetCellData>> _getGoogleSheetItems() {
    return <List<GoogleSheetCellData>>[
      for (final product in products)
        [
          GoogleSheetCellData(stringValue: product.catalog.name),
          GoogleSheetCellData(stringValue: product.name),
          GoogleSheetCellData(numberValue: product.price),
          GoogleSheetCellData(numberValue: product.cost),
          GoogleSheetCellData(stringValue: product._googleSheetIngredientInfo),
        ],
    ];
  }

  Product _formatValidGoogleSheetData(List<Object?> row) {
    final stringRow = row.map((e) => e.toString()).toList();

    final catalog = Catalog.fromColumns(
      getItemByName(stringRow[0]),
      stringRow,
    );
    Menu.instance.addItem(catalog);
    final product = Product.fromColumns(
      getProductByName(stringRow[1]),
      stringRow,
      catalog.newIndex,
    );
    catalog.addItem(product);

    if (row.length == 4 || row[4] == null) {
      return product;
    }

    product._parseGoogleSheetIngredientInfo(stringRow[4]);

    return product;
  }

  String? _validateGoogleSheetData(List<Object?> row) {
    if (row.length < 4) return S.importerColumnsCountError(4);

    final errorMsg = Validator.textLimit(S.menuCatalogNameLabel, 30)(
          row[0]?.toString(),
        ) ??
        Validator.textLimit(S.menuProductNameLabel, 30)(
          row[1]?.toString(),
        ) ??
        Validator.isNumber(S.menuProductPriceLabel)(
          row[2]?.toString(),
        ) ??
        Validator.positiveNumber(S.menuProductCostLabel)(
          row[3]?.toString(),
        );

    if (errorMsg != null || row.length == 4 || row[4] == null) return errorMsg;

    final lines = row[4].toString().split('\n');
    for (var line in lines) {
      if (line.startsWith('- ')) {
        final columns = line.substring(2).split(',');
        if (columns.length < 2) continue;

        final msg = Validator.textLimit(S.stockIngredientNameLabel, 30)(
                columns[0]) ??
            Validator.positiveNumber(S.stockIngredientAmountLabel)(columns[1]);
        if (msg != null) return msg;
      } else if (line.startsWith('  + ')) {
        final columns = line.substring(4).split(',');
        if (columns.length < 4) continue;

        final msg = Validator.textLimit(S.quantityNameLabel, 30)(columns[0]) ??
            Validator.positiveNumber(S.menuQuantityAmountLabel)(columns[1]) ??
            Validator.isNumber(S.menuQuantityAdditionalPriceLabel)(
                columns[2]) ??
            Validator.isNumber(S.menuQuantityAdditionalCostLabel)(columns[3]);
        if (msg != null) return msg;
      }
    }

    return null;
  }
}

extension GoogleSheetStockFormatter on Stock {
  List<GoogleSheetCellData> _getGoogleSheetHead() {
    return <GoogleSheetCellData>[
      _toCD(S.stockIngredientNameLabel),
      _toCD(S.stockIngredientAmountLabel),
    ];
  }

  List<List<GoogleSheetCellData>> _getGoogleSheetItems() {
    return <List<GoogleSheetCellData>>[
      for (final ingredient in itemList)
        [
          GoogleSheetCellData(stringValue: ingredient.name),
          ingredient.currentAmount == null
              ? GoogleSheetCellData(stringValue: '')
              : GoogleSheetCellData(numberValue: ingredient.currentAmount),
        ],
    ];
  }

  Ingredient _formatValidGoogleSheetData(List<Object?> row) {
    final stringRow = row.map((e) => e.toString()).toList();

    final ingredient = Ingredient.fromColumns(
      getItemByName(stringRow[0]),
      stringRow,
    );
    Stock.instance.addItem(ingredient);

    return ingredient;
  }

  String? _validateGoogleSheetData(List<Object?> row) {
    if (row.length < 2) return S.importerColumnsCountError(2);

    return Validator.textLimit(S.stockIngredientNameLabel, 30)(
          row[0]?.toString(),
        ) ??
        Validator.positiveNumber(S.stockIngredientAmountLabel)(
          row[1]?.toString(),
        );
  }
}

extension GoogleSheetQuantitiesFormatter on Quantities {
  List<GoogleSheetCellData> _getGoogleSheetHead() {
    return <GoogleSheetCellData>[
      _toCD(S.quantityNameLabel),
      _toCD(S.quantityProportionLabel, S.quantityProportionHelper),
    ];
  }

  List<List<GoogleSheetCellData>> _getGoogleSheetItems() {
    return <List<GoogleSheetCellData>>[
      for (final quantity in itemList)
        [
          GoogleSheetCellData(stringValue: quantity.name),
          GoogleSheetCellData(numberValue: quantity.defaultProportion),
        ],
    ];
  }

  Quantity _formatValidGoogleSheetData(List<Object?> row) {
    final stringRow = row.map((e) => e.toString()).toList();

    final ingredient = Quantity.fromColumns(
      getItemByName(stringRow[0]),
      stringRow,
    );
    Quantities.instance.addItem(ingredient);

    return ingredient;
  }

  String? _validateGoogleSheetData(List<Object?> row) {
    if (row.length < 2) return S.importerColumnsCountError(2);

    return Validator.textLimit(S.quantityNameLabel, 30)(
          row[0]?.toString(),
        ) ??
        Validator.positiveNumber(S.quantityProportionLabel, maximum: 100)(
          row[1]?.toString(),
        );
  }
}

extension GoogleSheetReplenisherFormatter on Replenisher {
  List<GoogleSheetCellData> _getGoogleSheetHead() {
    return <GoogleSheetCellData>[
      _toCD(S.stockReplenishmentNameLabel),
      _toCD(S.exporterReplenishmentTitle, S.exporterGSReplenishmentNote)
    ];
  }

  List<List<GoogleSheetCellData>> _getGoogleSheetItems() {
    return <List<GoogleSheetCellData>>[
      for (final repl in itemList)
        [
          GoogleSheetCellData(stringValue: repl.name),
          GoogleSheetCellData(stringValue: repl._googleSheetDataInfo),
        ],
    ];
  }

  Replenishment _formatValidGoogleSheetData(List<Object?> row) {
    final stringRow = row.map((e) => e.toString()).toList();

    final replenishment = Replenishment.fromColumns(
      getItemByName(stringRow[0]),
      stringRow,
    );
    Replenisher.instance.addItem(replenishment);

    replenishment._parseGoogleSheetData(stringRow[1]);

    return replenishment;
  }

  String? _validateGoogleSheetData(List<Object?> row) {
    if (row.length < 2) return S.importerColumnsCountError(2);

    return Validator.textLimit(S.stockReplenishmentNameLabel, 30)(
      row[0]?.toString(),
    );
  }
}

extension GoogleSheetCustomerSettingsFormatter on CustomerSettings {
  List<GoogleSheetCellData> _getGoogleSheetHead() {
    final note = CustomerSettingOptionMode.values
        .map((e) => S.customerSettingModeDescriptions(e))
        .join('\n');
    S.customerSettingModeDescriptions;
    return <GoogleSheetCellData>[
      _toCD(S.customerSettingNameLabel),
      _toCD(S.customerSettingModeTitle, note),
      _toCD(S.exporterCustomerSettingOptionTitle,
          S.exporterGSCustomerSettingOptionNote),
    ];
  }

  List<List<GoogleSheetCellData>> _getGoogleSheetItems() {
    return <List<GoogleSheetCellData>>[
      for (final setting in itemList)
        [
          GoogleSheetCellData(stringValue: setting.name),
          GoogleSheetCellData(
              stringValue: S.customerSettingModeNames(setting.mode)),
          GoogleSheetCellData(stringValue: setting._googleSheetDataInfo),
        ],
    ];
  }

  CustomerSetting _formatValidGoogleSheetData(List<Object?> row) {
    final stringRow = row.map((e) => e.toString()).toList();

    final customerSetting = CustomerSetting.fromColumns(
      getItemByName(stringRow[0]),
      stringRow,
    );
    CustomerSettings.instance.addItem(customerSetting);

    customerSetting._parseGoogleSheetData(stringRow[2]);

    return customerSetting;
  }

  String? _validateGoogleSheetData(List<Object?> row) {
    if (row.length < 2) return S.importerColumnsCountError(2);

    return Validator.textLimit(S.stockReplenishmentNameLabel, 30)(
      row[0]?.toString(),
    );
  }
}

extension GoogleSheetProductFormatter on Product {
  String get _googleSheetIngredientInfo => [
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

  void _parseGoogleSheetIngredientInfo(String value) {
    final lines = value.split('\n');
    ProductIngredient? ingredient;
    for (var line in lines) {
      if (line.startsWith('- ')) {
        final columns = line.substring(2).split(',');
        if (columns.length < 2) continue;

        ingredient = ProductIngredient.fromColumns(
          getItemByName(columns[0]),
          columns,
        );
        addItem(ingredient);
      } else if (ingredient != null && line.startsWith('  + ')) {
        final columns = line.substring(4).split(',');
        if (columns.length < 4) continue;

        final quantity = ProductQuantity.fromColumns(
          ingredient.getItemByName(columns[0]),
          columns,
        );
        ingredient.addItem(quantity);
      }
    }
  }
}

extension GoogleSheetReplenishmentFormatter on Replenishment {
  String get _googleSheetDataInfo => [
        for (final entry in ingredientData.entries)
          '- ${entry.key.name},${entry.value}',
      ].join('\n');

  void _parseGoogleSheetData(String value) {
    data.clear();
    // TODO
    data.addAll({});
  }
}

extension GoogleSheetCustomerSettingFormatter on CustomerSetting {
  String get _googleSheetDataInfo => [
        for (final item in itemList)
          '- ${item.name},${item.isDefault},${item.modeValue}',
      ].join('\n');

  void _parseGoogleSheetData(String value) {
    // TODO
    replaceItems({});
  }
}

GoogleSheetCellData _toCD(String title, [String? note]) {
  return GoogleSheetCellData(
    stringValue: title,
    note: note,
    isBold: true,
  );
}
