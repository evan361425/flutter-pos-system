import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/customer/customer_setting.dart';
import 'package:possystem/models/customer/customer_setting_option.dart';
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
  List<FormattedItem<T>> format<T extends Model>(
    Repository target,
    List<List<Object?>> rows,
  ) {
    final formatter = _getFormatter(target);
    final result = <FormattedItem<T>>[];

    bool existInResult(String name) {
      return result.any((e) => !e.hasError && e.item!.name == name);
    }

    for (var row in rows) {
      final r = row.map((e) => e.toString().trim()).toList();
      final msg = formatter.validate(r) ??
          (existInResult(r[formatter.nameIndex]) ? '將忽略本行，相同的項目已於前面出現' : null);

      if (msg != null) {
        result.add(
          FormattedItem<T>(
            error: FormatterValidateError(msg, row.join(' ')),
          ),
        );
      } else {
        result.add(FormattedItem<T>(item: formatter.format(r) as T));
      }
    }

    return result;
  }

  @override
  List<GoogleSheetCellData> getHeader(Repository target) =>
      _getFormatter(target).getHeader();

  @override
  List<List<GoogleSheetCellData>> getRows(Repository target) =>
      _getFormatter(target).getRows();

  _Formatter _getFormatter(Repository target) {
    if (target is Menu) {
      return _MenuFormatter(target);
    } else if (target is Stock) {
      return _StockFormatter(target);
    } else if (target is Quantities) {
      return _QuantitiesFormatter(target);
    } else if (target is Replenisher) {
      return _ReplenisherFormatter(target);
    } else if (target is CustomerSettings) {
      return _CSFormatter(target);
    }

    throw ArgumentError();
  }
}

abstract class _Formatter<T extends Repository, U extends Model> {
  final T target;

  final int nameIndex = 0;

  const _Formatter(this.target);

  List<GoogleSheetCellData> getHeader();

  List<List<GoogleSheetCellData>> getRows();

  String? validate(List<String> row);

  U format(List<String> row);
}

class _MenuFormatter extends _Formatter<Menu, Product> {
  const _MenuFormatter(Menu target) : super(target);

  @override
  int get nameIndex => 1;

  @override
  List<GoogleSheetCellData> getHeader() => <GoogleSheetCellData>[
        _toCD(S.menuCatalogNameLabel),
        _toCD(S.menuProductNameLabel),
        _toCD(S.menuProductPriceLabel),
        _toCD(S.menuProductCostLabel),
        _toCD(S.exporterProductIngredientInfoTitle,
            S.exporterGSProductIngredientInfoNote),
      ];

  @override
  List<List<GoogleSheetCellData>> getRows() {
    return target.products.map<List<GoogleSheetCellData>>((product) {
      final ingredientInfo = [
        for (var ingredient in product.items)
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

      return [
        GoogleSheetCellData(stringValue: product.catalog.name),
        GoogleSheetCellData(stringValue: product.name),
        GoogleSheetCellData(numberValue: product.price),
        GoogleSheetCellData(numberValue: product.cost),
        GoogleSheetCellData(stringValue: ingredientInfo),
      ];
    }).toList();
  }

  @override
  String? validate(List<String> row) {
    if (row.length < 4) return S.importerColumnsCountError(4);

    final errorMsg = Validator.textLimit(S.menuCatalogNameLabel, 30)(row[0]) ??
        Validator.textLimit(S.menuProductNameLabel, 30)(row[1]) ??
        Validator.isNumber(S.menuProductPriceLabel)(row[2]) ??
        Validator.positiveNumber(S.menuProductCostLabel)(row[3]);

    if (errorMsg != null || row.length == 4) return errorMsg;

    final lines = row[4].toString().split('\n');
    for (var line in lines) {
      if (line.startsWith('- ')) {
        final columns = line.substring(2).split(',');
        if (columns.length < 2) continue;

        final msg =
            Validator.textLimit(S.stockIngredientNameLabel, 30)(columns[0]) ??
                Validator.positiveNumber(
                  S.stockIngredientAmountLabel,
                  allowNull: true,
                )(columns[1]);
        if (msg != null) return msg;
      } else if (line.startsWith('  + ')) {
        final columns = line.substring(4).split(',');
        if (columns.length < 4) continue;

        final msg = Validator.textLimit(S.quantityNameLabel, 30)(columns[0]) ??
            Validator.positiveNumber(
              S.menuQuantityAmountLabel,
              allowNull: true,
            )(columns[1]);
        if (msg != null) return msg;
      }
    }

    return null;
  }

  @override
  Product format(List<String> row) {
    final catalog = target.getStagedByName(row[0]) ??
        Catalog.fromRow(target.getItemByName(row[0]), row);
    Menu.instance.addStaged(catalog);

    final oriProduct = target.getProductByName(row[1]);
    final product = Product.fromRow(oriProduct, row);
    catalog.addItem(product, save: false);

    return row.length == 4
        ? product
        : _formatProduct(oriProduct, product, row[4]);
  }

  Product _formatProduct(Product? ori, Product product, String value) {
    final lines = value.split('\n');
    ProductIngredient? ingredient;
    ProductIngredient? oriIngredient;

    for (var line in lines) {
      if (line.startsWith('- ')) {
        final columns = line.substring(2).split(',');
        if (columns.isEmpty) continue;

        oriIngredient = ori?.getItemByName(columns[0]);
        ingredient = ProductIngredient.fromRow(oriIngredient, columns);
        product.addItem(ingredient, save: false);
      } else if (ingredient != null && line.startsWith('  + ')) {
        final columns = line.substring(4).split(',');
        if (columns.isEmpty) continue;

        final quantity = ProductQuantity.fromRow(
          oriIngredient?.getItemByName(columns[0]),
          columns,
        );
        ingredient.addItem(quantity, save: false);
      }
    }

    return product;
  }
}

class _StockFormatter extends _Formatter<Stock, Ingredient> {
  const _StockFormatter(Stock target) : super(target);

  @override
  List<GoogleSheetCellData> getHeader() => <GoogleSheetCellData>[
        _toCD(S.stockIngredientNameLabel),
        _toCD(S.stockIngredientAmountLabel),
      ];

  @override
  List<List<GoogleSheetCellData>> getRows() => target.itemList
      .map((ingredient) => [
            GoogleSheetCellData(stringValue: ingredient.name),
            ingredient.currentAmount == null
                ? GoogleSheetCellData(stringValue: '')
                : GoogleSheetCellData(numberValue: ingredient.currentAmount),
          ])
      .toList();

  @override
  String? validate(List<String> row) {
    if (row.length < 2) return S.importerColumnsCountError(2);

    return Validator.textLimit(S.stockIngredientNameLabel, 30)(row[0]) ??
        Validator.positiveNumber(S.stockIngredientAmountLabel)(row[1]);
  }

  @override
  Ingredient format(List<String> row) {
    final ingredient = Ingredient.fromRow(target.getItemByName(row[0]), row);
    Stock.instance.addStaged(ingredient);

    return ingredient;
  }
}

class _QuantitiesFormatter extends _Formatter<Quantities, Quantity> {
  const _QuantitiesFormatter(Quantities target) : super(target);

  @override
  List<GoogleSheetCellData> getHeader() => <GoogleSheetCellData>[
        _toCD(S.quantityNameLabel),
        _toCD(S.quantityProportionLabel, S.quantityProportionHelper),
      ];

  @override
  List<List<GoogleSheetCellData>> getRows() => target.itemList
      .map((quantity) => [
            GoogleSheetCellData(stringValue: quantity.name),
            GoogleSheetCellData(numberValue: quantity.defaultProportion),
          ])
      .toList();

  @override
  String? validate(List<String> row) {
    if (row.length < 2) return S.importerColumnsCountError(2);

    return Validator.textLimit(S.quantityNameLabel, 30)(row[0]) ??
        Validator.positiveNumber(S.quantityProportionLabel, maximum: 100)(
          row[1],
        );
  }

  @override
  Quantity format(List<String> row) {
    final quantity = Quantity.fromRow(target.getItemByName(row[0]), row);
    Quantities.instance.addStaged(quantity);

    return quantity;
  }
}

class _ReplenisherFormatter extends _Formatter<Replenisher, Replenishment> {
  const _ReplenisherFormatter(Replenisher target) : super(target);

  @override
  List<GoogleSheetCellData> getHeader() => <GoogleSheetCellData>[
        _toCD(S.stockReplenishmentNameLabel),
        _toCD(S.exporterReplenishmentTitle, S.exporterGSReplenishmentNote)
      ];

  @override
  List<List<GoogleSheetCellData>> getRows() => target.itemList.map((e) {
        final info = [
          for (final entry in e.ingredientData.entries)
            '- ${entry.key.name},${entry.value}',
        ].join('\n');
        return [
          GoogleSheetCellData(stringValue: e.name),
          GoogleSheetCellData(stringValue: info),
        ];
      }).toList();

  @override
  String? validate(List<String> row) {
    if (row.isEmpty) return S.importerColumnsCountError(1);

    final errorMsg =
        Validator.textLimit(S.stockReplenishmentNameLabel, 30)(row[0]);
    if (errorMsg != null || row.length == 1) return errorMsg;

    final lines = row[2].toString().split('\n');
    for (var line in lines) {
      if (line.startsWith('- ')) {
        final columns = line.substring(2).split(',');
        if (columns.isEmpty) continue;

        final msg =
            Validator.textLimit(S.stockIngredientNameLabel, 30)(columns[0]);
        if (msg != null) return msg;
      }
    }

    return null;
  }

  @override
  Replenishment format(List<String> row) {
    final rep = Replenishment.fromRow(target.getItemByName(row[0]), row);
    Replenisher.instance.addStaged(rep);

    return row.length == 1 ? rep : _formatRep(rep, row[1]);
  }

  Replenishment _formatRep(Replenishment rep, String value) {
    final lines = value.split('\n');
    for (var line in lines) {
      if (!line.startsWith('- ')) continue;

      final columns = line.substring(2).split(',');
      if (columns.length < 2) continue;

      rep.supplyByStrings(columns);
    }

    return rep;
  }
}

class _CSFormatter extends _Formatter<CustomerSettings, CustomerSetting> {
  const _CSFormatter(CustomerSettings target) : super(target);

  @override
  List<GoogleSheetCellData> getHeader() {
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

  @override
  List<List<GoogleSheetCellData>> getRows() => target.itemList.map((e) {
        final info = [
          for (final item in e.itemList)
            '- ${item.name},${item.isDefault},${item.modeValue}',
        ].join('\n');
        return [
          GoogleSheetCellData(stringValue: e.name),
          GoogleSheetCellData(stringValue: S.customerSettingModeNames(e.mode)),
          GoogleSheetCellData(stringValue: info),
        ];
      }).toList();

  @override
  String? validate(List<String> row) {
    if (row.length < 2) return S.importerColumnsCountError(2);

    final msg = Validator.textLimit(S.customerSettingNameLabel, 30)(row[0]);
    final mode = str2CustomerSettingOptionMode(row[1]);
    if (msg != null || row.length == 2) return msg;

    final lines = row[2].toString().split('\n');
    for (var line in lines) {
      if (line.startsWith('- ')) {
        final columns = line.substring(2).split(',');
        if (columns.isEmpty) continue;

        final checkValue = columns.length > 2 &&
            mode == CustomerSettingOptionMode.changeDiscount;

        final err = Validator.textLimit(S.customerSettingOptionNameLabel, 30)(
                columns[0]) ??
            (checkValue
                ? Validator.positiveInt(S.customerSettingModeNames(mode),
                    maximum: 1000, allowNull: true)(columns[2])
                : null);
        if (err != null) return err;
      }
    }

    return null;
  }

  @override
  CustomerSetting format(List<String> row) {
    final oriCs = target.getItemByName(row[0]);
    final cs = CustomerSetting.fromRow(oriCs, row);
    CustomerSettings.instance.addStaged(cs);

    return row.length == 2 ? cs : _formatCS(oriCs, cs, row[2]);
  }

  CustomerSetting _formatCS(
    CustomerSetting? ori,
    CustomerSetting cs,
    String value,
  ) {
    final lines = value.split('\n');
    for (var line in lines) {
      if (!line.startsWith('- ')) continue;

      final columns = line.substring(2).split(',');
      if (columns.isEmpty) continue;

      final option = CustomerSettingOption.fromRow(
        ori,
        ori?.getItemByName(columns[0]),
        columns,
      );
      cs.addItem(option, save: false);
    }

    return cs;
  }
}

GoogleSheetCellData _toCD(String title, [String? note]) {
  return GoogleSheetCellData(
    stringValue: title,
    note: note,
    isBold: true,
  );
}
