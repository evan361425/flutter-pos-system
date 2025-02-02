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

  /// Parse row (list of string) to specific [Model]
  ModelParser toParser() {
    switch (this) {
      case FormattableModel.menu:
        return MenuParser(Menu.instance);
      case FormattableModel.stock:
        return StockParser(Stock.instance);
      case FormattableModel.quantities:
        return QuantitiesParser(Quantities.instance);
      case FormattableModel.replenisher:
        return ReplenisherParser(Replenisher.instance);
      case FormattableModel.orderAttr:
        return OAParser(OrderAttributes.instance);
    }
  }

  Repository toRepository() {
    switch (this) {
      case FormattableModel.menu:
        return Menu.instance;
      case FormattableModel.stock:
        return Stock.instance;
      case FormattableModel.quantities:
        return Quantities.instance;
      case FormattableModel.replenisher:
        return Replenisher.instance;
      case FormattableModel.orderAttr:
        return OrderAttributes.instance;
    }
  }

  Future<void> finishPreview(bool? willCommit) async {
    if (willCommit == true) {
      await toRepository().commitStaged();
    } else {
      toRepository().abortStaged();
    }
  }
}

enum FormattableOrder {
  basic('order'),
  attr('orderDetailsAttr'),
  product('orderDetailsProduct'),
  ingredient('orderDetailsIngredient');

  final String l10nName;

  const FormattableOrder(this.l10nName);

  List<List<CellData>> formatRows(OrderObject order) {
    switch (this) {
      case FormattableOrder.attr:
        return OrderFormatter.formatAttr(order);
      case FormattableOrder.product:
        return OrderFormatter.formatProduct(order);
      case FormattableOrder.ingredient:
        return OrderFormatter.formatIngredient(order);
      default:
        return OrderFormatter.formatBasic(order);
    }
  }

  List<String> formatHeader() {
    switch (this) {
      case FormattableOrder.attr:
        return OrderFormatter.attrHeaders;
      case FormattableOrder.product:
        return OrderFormatter.productHeaders;
      case FormattableOrder.ingredient:
        return OrderFormatter.ingredientHeaders;
      default:
        return OrderFormatter.basicHeaders;
    }
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
          msg = S.transitImportErrorDuplicate;
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
