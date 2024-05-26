import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/translator.dart';

enum Formattable {
  menu,
  stock,
  quantities,
  replenisher,
  orderAttr,
}

abstract class Formatter<T> {
  const Formatter();

  List<FormattedItem<U>> format<U extends Model>(
    Formattable able,
    List<List<Object?>> rows,
  ) {
    final transformer = getTransformer(able);
    final parsed = transformer.parseRows(rows);

    final formatter = getFormatter(able);
    final result = <FormattedItem<U>>[];

    bool existInResult(String name) {
      return result.any((e) => !e.hasError && e.item!.name == name);
    }

    int counter = 1;
    for (var row in parsed) {
      final r = row.map((e) => e.trim()).toList();
      final msg =
          formatter.validate(r) ?? (existInResult(r[formatter.nameIndex]) ? S.transitImportErrorDuplicate : null);

      if (msg != null) {
        result.add(
          FormattedItem<U>(
            error: FormatterValidateError(msg, row.join(' ')),
          ),
        );
      } else {
        result.add(FormattedItem<U>(item: formatter.format(r, counter++) as U));
      }
    }

    return result;
  }

  List<T> getHeader(Formattable able) => getTransformer(able).getHeader() as List<T>;

  List<List<T>> getRows(Formattable able) => getTransformer(able).getRows() as List<List<T>>;

  ModelFormatter getFormatter(Formattable able) {
    switch (able) {
      case Formattable.menu:
        return _MenuFormatter(Menu.instance);
      case Formattable.stock:
        return _StockFormatter(Stock.instance);
      case Formattable.quantities:
        return _QuantitiesFormatter(Quantities.instance);
      case Formattable.replenisher:
        return _ReplenisherFormatter(Replenisher.instance);
      case Formattable.orderAttr:
        return _OAFormatter(OrderAttributes.instance);
    }
  }

  ModelTransformer getTransformer(Formattable able);

  static Formattable nameToFormattable(String name) {
    return Formattable.values.firstWhere((e) => e.name == name);
  }

  static Repository getTarget(Formattable able) {
    switch (able) {
      case Formattable.menu:
        return Menu.instance;
      case Formattable.stock:
        return Stock.instance;
      case Formattable.quantities:
        return Quantities.instance;
      case Formattable.replenisher:
        return Replenisher.instance;
      case Formattable.orderAttr:
        return OrderAttributes.instance;
    }
  }

  static Future<void> finishFormat(Formattable able, [bool? willCommit]) async {
    final target = getTarget(able);
    if (willCommit == true) {
      await target.commitStaged();
    } else {
      target.abortStaged();
    }
  }
}

class FormatterValidateError extends Error {
  final String message;

  final String raw;

  FormatterValidateError(this.message, this.raw);
}

class FormattedItem<T extends Model> {
  final T? item;

  final FormatterValidateError? error;

  const FormattedItem({this.item, this.error});

  bool get hasError => error != null;
}

abstract class ModelFormatter<T extends Repository, U extends Model> {
  final T target;

  const ModelFormatter(this.target);

  int get nameIndex => 0;

  /// Return error message if invalid
  String? validate(List<String> row);

  /// Format row to specific [Model]
  ///
  /// [index] 1-index
  U format(List<String> row, int index);
}

abstract class ModelTransformer<T extends Repository> {
  final T target;

  const ModelTransformer(this.target);

  List<Object> getHeader();

  List<List<Object>> getRows();

  List<List<String>> parseRows(List<List<Object?>> rows) {
    return rows.map((row) => row.map((e) => e.toString().trim()).toList()).toList();
  }
}

class _MenuFormatter extends ModelFormatter<Menu, Product> {
  const _MenuFormatter(super.target);

  @override
  int get nameIndex => 1;

  @override
  String? validate(List<String> row) {
    if (row.length < 4) return S.transitImportErrorColumnCount(4);

    final errorMsg = Validator.textLimit(S.menuCatalogNameLabel, 30)(row[0]) ??
        Validator.textLimit(S.menuProductNameLabel, 30)(row[1]) ??
        Validator.isNumber(S.menuProductPriceLabel)(row[2]) ??
        Validator.positiveNumber(S.menuProductCostLabel)(row[3]);

    if (errorMsg != null || row.length == 4) return errorMsg;

    final vIng = Validator.textLimit(S.stockIngredientNameLabel, 30);
    final vQua = Validator.textLimit(S.stockQuantityNameLabel, 30);
    final vAmount = Validator.positiveNumber(
      S.stockIngredientAmountLabel,
      allowNull: true,
    );
    final vQuaAmount = Validator.positiveNumber(
      S.menuQuantityAmountLabel,
      allowNull: true,
    );

    final lines = row[4].toString().split('\n').map((e) => e.trim());
    for (final line in lines) {
      if (line.startsWith('- ')) {
        final columns = line.substring(2).split(',');

        final msg = (columns.isEmpty ? null : vIng(columns[0])) ?? (columns.length < 2 ? null : vAmount(columns[1]));
        if (msg != null) return msg;
      } else if (line.startsWith('+ ')) {
        final columns = line.substring(2).split(',');

        final msg = (columns.isEmpty ? null : vQua(columns[0])) ?? (columns.length < 2 ? null : vQuaAmount(columns[1]));
        if (msg != null) return msg;
      }
    }

    return null;
  }

  @override
  Product format(List<String> row, int index) {
    final catalog = target.getStagedByName(row[0]) ??
        Catalog.fromRow(
          target.getItemByName(row[0]),
          row,
          index: Menu.instance.stagedItems.length + 1,
        );
    Menu.instance.addStaged(catalog);

    final oriProduct = target.getProductByName(row[1]);
    final product = Product.fromRow(oriProduct, row, index: index);
    catalog.addItem(product, save: false);

    return row.length == 4 ? product : _formatProduct(oriProduct, product, row[4]);
  }

  Product _formatProduct(Product? ori, Product product, String value) {
    final lines = value.split('\n');
    ProductIngredient? ingredient;
    ProductIngredient? oriIngredient;

    for (var line in lines.map((e) => e.trim())) {
      if (line.startsWith('- ')) {
        final columns = line.substring(2).split(',');
        if (columns.isEmpty) continue;

        oriIngredient = ori?.getItemByName(columns[0]);
        ingredient = ProductIngredient.fromRow(oriIngredient, columns);
        product.addItem(ingredient, save: false);
      } else if (ingredient != null && line.startsWith('+ ')) {
        final columns = line.substring(2).split(',');
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

class _StockFormatter extends ModelFormatter<Stock, Ingredient> {
  const _StockFormatter(super.target);

  @override
  String? validate(List<String> row) {
    if (row.isEmpty) return S.transitImportErrorColumnCount(1);

    return Validator.textLimit(S.stockIngredientNameLabel, 30)(row[0]) ??
        Validator.positiveNumber(
          S.stockIngredientAmountLabel,
          allowNull: true,
        )(row.length > 1 ? row[1] : null) ??
        Validator.positiveNumber(
          S.stockIngredientRestockPriceLabel,
          allowNull: true,
        )(row.length > 2 ? row[2] : null) ??
        Validator.positiveNumber(
          S.stockIngredientRestockQuantityLabel,
          allowNull: true,
        )(row.length > 3 ? row[3] : null);
  }

  @override
  Ingredient format(List<String> row, int index) {
    final ingredient = Ingredient.fromRow(target.getItemByName(row[0]), row);
    Stock.instance.addStaged(ingredient);

    return ingredient;
  }
}

class _QuantitiesFormatter extends ModelFormatter<Quantities, Quantity> {
  const _QuantitiesFormatter(super.target);

  @override
  String? validate(List<String> row) {
    if (row.isEmpty) return S.transitImportErrorColumnCount(1);

    return Validator.textLimit(S.stockQuantityNameLabel, 30)(row[0]) ??
        Validator.positiveNumber(
          S.stockQuantityProportionLabel,
          maximum: 100,
          allowNull: true,
        )(row.length > 1 ? row[1] : null);
  }

  @override
  Quantity format(List<String> row, int index) {
    final quantity = Quantity.fromRow(target.getItemByName(row[0]), row);
    Quantities.instance.addStaged(quantity);

    return quantity;
  }
}

class _ReplenisherFormatter extends ModelFormatter<Replenisher, Replenishment> {
  const _ReplenisherFormatter(super.target);

  @override
  String? validate(List<String> row) {
    if (row.isEmpty) return S.transitImportErrorColumnCount(1);

    final errorMsg = Validator.textLimit(S.stockReplenishmentNameLabel, 30)(row[0]);
    if (errorMsg != null || row.length == 1) return errorMsg;

    final lines = row[1].split('\n');
    final vName = Validator.textLimit(S.stockIngredientNameLabel, 30);
    for (var line in lines) {
      if (line.startsWith('- ')) {
        final columns = line.substring(2).split(',');

        final msg = vName(columns[0]);
        if (msg != null) return msg;
      }
    }

    return null;
  }

  @override
  Replenishment format(List<String> row, int index) {
    final rep = Replenishment.fromRow(
      target.getItemByName(row[0]),
      row,
      row.length == 1 ? <String, num>{} : _formatRep(row[1]),
    );
    Replenisher.instance.addStaged(rep);

    return rep;
  }

  Map<String, num> _formatRep(String value) {
    final data = <String, num>{};
    final lines = value.split('\n');
    for (var line in lines.map((e) => e.trim())) {
      if (!line.startsWith('- ')) continue;

      final columns = line.substring(2).split(',');
      if (columns.length < 2) continue;

      final amount = num.tryParse(columns[1]);
      if (amount == null) continue;

      Ingredient? ing = Stock.instance.getItemByName(columns[0]);
      if (ing == null) {
        ing = Ingredient(
          name: columns[0],
          status: ModelStatus.staged,
        );
        Stock.instance.addStaged(ing);
      }

      data[ing.id] = amount;
    }

    return data;
  }
}

class _OAFormatter extends ModelFormatter<OrderAttributes, OrderAttribute> {
  const _OAFormatter(super.target);

  @override
  String? validate(List<String> row) {
    if (row.length < 2) return S.transitImportErrorColumnCount(2);

    final msg = Validator.textLimit(S.orderAttributeNameLabel, 30)(row[0]);
    if (msg != null || row.length == 2) return msg;

    final lines = row[2].toString().split('\n');
    final shouldValidateMode = _str2mode(row[1]) == OrderAttributeMode.changeDiscount;
    final vName = Validator.textLimit(S.orderAttributeOptionNameLabel, 30);
    final vMode = Validator.positiveInt(row[1], maximum: 1000, allowNull: true);
    for (var line in lines) {
      if (line.startsWith('- ')) {
        final columns = line.substring(2).split(',');

        final err = vName(columns[0]) ?? (columns.length > 2 && shouldValidateMode ? vMode(columns[2]) : null);
        if (err != null) return err;
      }
    }

    return null;
  }

  @override
  OrderAttribute format(List<String> row, int index) {
    final ori = target.getItemByName(row[0]);
    final attr = OrderAttribute.fromRow(
      ori,
      row,
      index: index,
      mode: _str2mode(row[1]),
    );
    OrderAttributes.instance.addStaged(attr);

    if (row.length >= 3) {
      for (var option in _formatOptions(ori, row[2])) {
        attr.addItem(option, save: false);
      }
    }

    return attr;
  }

  Iterable<OrderAttributeOption> _formatOptions(
    OrderAttribute? ori,
    String value,
  ) sync* {
    final lines = value.split('\n');
    int counter = 1;
    for (var line in lines.map((e) => e.trim())) {
      if (!line.startsWith('- ')) continue;

      final columns = line.substring(2).split(',');

      yield OrderAttributeOption.fromRow(
        ori?.getItemByName(columns[0]),
        columns,
        index: counter++,
      );
    }
  }

  OrderAttributeMode _str2mode(String key) {
    for (final e in OrderAttributeMode.values) {
      if (S.orderAttributeModeName(e.name) == key) {
        return e;
      }
    }

    return OrderAttributeMode.statOnly;
  }
}
