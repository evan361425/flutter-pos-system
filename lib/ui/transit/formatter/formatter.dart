import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/model_parser.dart';
import 'package:possystem/ui/transit/formatter/order_formatter.dart';

enum FormattableModel {
  menu,
  stock,
  quantities,
  replenisher,
  orderAttr;

  static FormattableModel find(String name) {
    return FormattableModel.values.firstWhere((e) => e.name == name);
  }

  static void abort() {
    for (var e in FormattableModel.values) {
      e.toRepository().abortStaged();
    }
  }

  static List<String> get allL10nNames => FormattableModel.values.map((e) => e.l10nName).toList();

  String get l10nName => S.transitModelName(name);

  /// Useful to do null fallback with [FormattableModel.values]
  ///
  /// Example:
  /// ```dart
  /// final model = able?.l10nNames ?? FormattableModel.values.map((e) => e.l10nName).toList();
  /// ```
  List<String> toL10nNames() => [l10nName];

  List<FormattableModel> toList() => [this];

  /// Parse row (list of string) to specific [Model]
  ModelParser toParser() {
    return switch (this) {
      FormattableModel.menu => MenuParser(Menu.instance) as ModelParser,
      FormattableModel.stock => StockParser(Stock.instance),
      FormattableModel.quantities => QuantitiesParser(Quantities.instance),
      FormattableModel.replenisher => ReplenisherParser(Replenisher.instance),
      FormattableModel.orderAttr => OAParser(OrderAttributes.instance),
    };
  }

  Repository toRepository() {
    return switch (this) {
      FormattableModel.menu => Menu.instance as Repository,
      FormattableModel.stock => Stock.instance,
      FormattableModel.quantities => Quantities.instance,
      FormattableModel.replenisher => Replenisher.instance,
      FormattableModel.orderAttr => OrderAttributes.instance,
    };
  }
}

enum FormattableOrder {
  basic,
  attr,
  product,
  ingredient;

  String get l10nName => S.transitOrderName(name);

  List<List<CellData>> formatRows(OrderObject order) {
    return switch (this) {
      FormattableOrder.attr => OrderFormatter.formatAttr(order),
      FormattableOrder.product => OrderFormatter.formatProduct(order),
      FormattableOrder.ingredient => OrderFormatter.formatIngredient(order),
      _ => OrderFormatter.formatBasic(order),
    };
  }

  List<String> formatHeader() {
    return switch (this) {
      FormattableOrder.attr => OrderFormatter.attrHeaders,
      FormattableOrder.product => OrderFormatter.productHeaders,
      FormattableOrder.ingredient => OrderFormatter.ingredientHeaders,
      _ => OrderFormatter.basicHeaders,
    };
  }
}

class CellData {
  final String? string;
  final num? number;

  /// Note is help text when hover on the cell
  final String? note;

  /// Options is used for dropdown
  final List<String>? options;

  /// Bold the text
  final bool? isBold;

  CellData({
    this.string,
    this.number,
    this.note,
    this.options,
    this.isBold,
  });

  @override
  String toString() {
    return string ?? number?.toString() ?? '';
  }

  Object get value => string ?? number ?? '';
}

abstract class ModelFormatter<T extends Repository, U> {
  final T target;
  final ModelParser parser;

  const ModelFormatter(this.target, this.parser);

  List<U> getHeader();

  List<List<U>> getRows();

  List<FormattedItem<M>> format<M extends Model>(List<List<Object?>> rows) {
    final data = rows.map((row) => row.map((e) => e.toString().trim()).toList()).toList();
    final transformed = this.transformRows(data);

    final result = <FormattedItem<M>>[];

    int counter = 1;
    for (final row in transformed) {
      final r = row.map((e) => e.trim()).toList();
      var msg = parser.validate(r);
      if (msg == null) {
        final name = r[parser.nameIndex];
        // check if the name is duplicated
        if (result.any((e) => !e.hasError && e.item!.name == name)) {
          msg = S.transitImportErrorBasicDuplicate;
        }
      }

      if (msg != null) {
        result.add(FormattedItem<M>(error: FormatterValidateError(msg, row.join(' '))));
      } else {
        result.add(FormattedItem<M>(item: parser.parse(r, counter++) as M));
      }
    }

    return result;
  }

  /// Transform rows to specific format
  ///
  /// Input is raw data, output is structured data.
  ///
  /// Currently, it's used for PlainText.
  List<List<String>> transformRows(List<List<String>> rows) => rows;
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
