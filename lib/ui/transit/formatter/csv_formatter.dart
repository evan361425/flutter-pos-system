import 'package:flutter/material.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';

class CSVFormatter extends Formatter<CellData> {
  const CSVFormatter();

  static List<String> split(String line) {
    List<String> row = [];
    StringBuffer field = StringBuffer();
    bool inQuotes = false;
    bool skip = false;

    final chars = line.characters;
    for (final (i, char) in chars.indexed) {
      if (skip) {
        skip = false;
        continue;
      }

      if (char == '"') {
        // Handle escaped double quotes ("")
        if (inQuotes && chars.elementAtOrNull(i + 1) == '"') {
          field.write('"');
          skip = true;
          continue;
        }

        if (!inQuotes && field.isNotEmpty) {
          throw FormatException('Unexpected quote', line, i);
        }

        // Toggle quote state
        inQuotes = !inQuotes;
        continue;
      }

      if (char == ',' && !inQuotes) {
        // End of field
        row.add(field.toString().trim());
        field.clear();
        continue;
      }

      // Regular character
      field.write(char);
    }

    // Add the last field and row
    if (field.isNotEmpty) {
      row.add(field.toString().trim());
    }

    return row;
  }

  @override
  ModelTransformer getTransformer(Formattable able) {
    switch (able) {
      case Formattable.menu:
        return _MenuTransformer(Menu.instance);
      case Formattable.stock:
        return _StockTransformer(Stock.instance);
      case Formattable.quantities:
        return _QuantitiesTransformer(Quantities.instance);
      case Formattable.replenisher:
        return _ReplenisherTransformer(Replenisher.instance);
      case Formattable.orderAttr:
        return _OATransformer(OrderAttributes.instance);
    }
  }
}

class _MenuTransformer extends ModelTransformer<Menu, CellData> {
  const _MenuTransformer(super.target);

  @override
  List<CellData> getHeader() => [
        CellData(string: S.menuCatalogNameLabel),
        CellData(string: S.menuProductNameLabel),
        CellData(string: S.menuProductPriceLabel),
        CellData(string: S.menuProductCostLabel),
        CellData(string: S.transitGSModelProductIngredientTitle),
        CellData(string: S.transitGSModelProductIngredientNote),
      ];

  @override
  List<List<CellData>> getRows() {
    return target.products.map<List<CellData>>((product) {
      final ingredientInfo = [
        for (var ingredient in product.items)
          '- ${ingredient.name},${ingredient.amount}${ingredient.itemList.map((quantity) => <String>[
                '\n  + ${quantity.name}',
                quantity.amount.toString(),
                quantity.additionalPrice.toString(),
                quantity.additionalCost.toString(),
              ].join(',')).join('')}'
      ].join('\n');

      return [
        CellData(string: product.catalog.name),
        CellData(string: product.name),
        CellData(number: product.price),
        CellData(number: product.cost),
        CellData(string: ingredientInfo),
      ];
    }).toList();
  }
}

class _StockTransformer extends ModelTransformer<Stock, CellData> {
  const _StockTransformer(super.target);

  @override
  List<CellData> getHeader() => [
        CellData(string: S.stockIngredientNameLabel),
        CellData(string: S.stockIngredientAmountLabel),
        CellData(string: S.stockIngredientAmountMaxLabel),
        CellData(string: S.stockIngredientRestockPriceLabel),
        CellData(string: S.stockIngredientRestockQuantityLabel),
      ];

  @override
  List<List<CellData>> getRows() => target.itemList
      .map((ingredient) => [
            CellData(string: ingredient.name),
            CellData(number: ingredient.currentAmount),
            CellData(number: ingredient.totalAmount),
            CellData(number: ingredient.restockPrice),
            CellData(number: ingredient.restockQuantity),
          ])
      .toList();
}

class _QuantitiesTransformer extends ModelTransformer<Quantities, CellData> {
  const _QuantitiesTransformer(super.target);

  @override
  List<CellData> getHeader() => [
        CellData(string: S.stockQuantityNameLabel),
        CellData(string: S.stockQuantityProportionLabel, note: S.stockQuantityProportionHelper),
      ];

  @override
  List<List<CellData>> getRows() => target.itemList
      .map((quantity) => [
            CellData(string: quantity.name),
            CellData(number: quantity.defaultProportion),
          ])
      .toList();
}

class _ReplenisherTransformer extends ModelTransformer<Replenisher, CellData> {
  const _ReplenisherTransformer(super.target);

  @override
  List<CellData> getHeader() => [
        CellData(string: S.stockReplenishmentNameLabel),
        CellData(string: S.transitGSModelReplenishmentTitle, note: S.transitGSModelReplenishmentNote),
      ];

  @override
  List<List<CellData>> getRows() => target.itemList.map((e) {
        final info = [
          for (final entry in e.ingredientData.entries) '- ${entry.key.name},${entry.value}',
        ].join('\n');
        return [
          CellData(string: e.name),
          CellData(string: info),
        ];
      }).toList();
}

class _OATransformer extends ModelTransformer<OrderAttributes, CellData> {
  const _OATransformer(super.target);

  @override
  List<CellData> getHeader() {
    final note = OrderAttributeMode.values
        .map((e) => '${S.orderAttributeModeName(e.name)} -  ${S.orderAttributeModeHelper(e.name)}')
        .join('\n');
    return <CellData>[
      CellData(string: S.orderAttributeNameLabel),
      CellData(string: S.orderAttributeModeDivider, note: note),
      CellData(string: S.transitGSModelAttributeOptionTitle, note: S.transitGSModelAttributeOptionNote),
    ];
  }

  @override
  List<List<CellData>> getRows() {
    final options = OrderAttributeMode.values.map((e) => S.orderAttributeModeName(e.name)).toList();

    return target.itemList.map((e) {
      final info = [
        for (final item in e.itemList) '- ${item.name},${item.isDefault},${item.modeValue ?? ''}',
      ].join('\n');
      return [
        CellData(string: e.name),
        CellData(string: S.orderAttributeModeName(e.mode.name), options: options),
        CellData(string: info),
      ];
    }).toList();
  }
}

class CellData {
  final String? string;
  final num? number;

  /// Note is help text when hover on the cell
  final String? note;

  /// Options is used for dropdown
  final List<String>? options;

  CellData({
    this.string,
    this.number,
    this.note,
    this.options,
  }) : assert(string != null || number != null);

  @override
  String toString() {
    return string ?? number!.toString();
  }
}
