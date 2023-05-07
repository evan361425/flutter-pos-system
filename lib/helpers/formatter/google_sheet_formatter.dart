import 'package:possystem/helpers/exporter/google_sheet_exporter.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';

class GoogleSheetFormatter extends Formatter<GoogleSheetCellData> {
  const GoogleSheetFormatter();

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

class _MenuTransformer extends ModelTransformer<Menu> {
  const _MenuTransformer(Menu target) : super(target);

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
          '- ${ingredient.name},${ingredient.amount}${ingredient.itemList.map((quantity) => <String>[
                '\n  + ${quantity.name}',
                quantity.amount.toString(),
                quantity.additionalPrice.toString(),
                quantity.additionalCost.toString(),
              ].join(',')).join('')}'
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
}

class _StockTransformer extends ModelTransformer<Stock> {
  const _StockTransformer(Stock target) : super(target);

  @override
  List<GoogleSheetCellData> getHeader() => <GoogleSheetCellData>[
        _toCD(S.stockIngredientNameLabel),
        _toCD(S.stockIngredientAmountLabel),
        _toCD(S.stockIngredientTotalAmountLabel),
      ];

  @override
  List<List<GoogleSheetCellData>> getRows() => target.itemList
      .map((ingredient) => [
            GoogleSheetCellData(stringValue: ingredient.name),
            GoogleSheetCellData(numberValue: ingredient.currentAmount),
            GoogleSheetCellData(numberValue: ingredient.totalAmount),
          ])
      .toList();
}

class _QuantitiesTransformer extends ModelTransformer<Quantities> {
  const _QuantitiesTransformer(Quantities target) : super(target);

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
}

class _ReplenisherTransformer extends ModelTransformer<Replenisher> {
  const _ReplenisherTransformer(Replenisher target) : super(target);

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
}

class _OATransformer extends ModelTransformer<OrderAttributes> {
  const _OATransformer(OrderAttributes target) : super(target);

  @override
  List<GoogleSheetCellData> getHeader() {
    final note = OrderAttributeMode.values
        .map((e) =>
            '${S.orderAttributeModeNames(e.name)} -  ${S.orderAttributeModeDescriptions(e.name)}')
        .join('\n');
    return <GoogleSheetCellData>[
      _toCD(S.orderAttributeNameLabel),
      _toCD(S.orderAttributeModeTitle, note),
      _toCD(S.exporterOrderAttributeOptionTitle,
          S.exporterGSOrderAttributeOptionNote),
    ];
  }

  @override
  List<List<GoogleSheetCellData>> getRows() {
    final options = OrderAttributeMode.values
        .map((e) => S.orderAttributeModeNames(e.name))
        .toList();

    return target.itemList.map((e) {
      final info = [
        for (final item in e.itemList)
          '- ${item.name},${item.isDefault},${item.modeValue ?? ''}',
      ].join('\n');
      return [
        GoogleSheetCellData(stringValue: e.name),
        GoogleSheetCellData(
          options: options,
          stringValue: S.orderAttributeModeNames(e.mode.name),
        ),
        GoogleSheetCellData(stringValue: info),
      ];
    }).toList();
  }
}

GoogleSheetCellData _toCD(String title, [String? note]) {
  return GoogleSheetCellData(
    stringValue: title,
    note: note,
    isBold: true,
  );
}
