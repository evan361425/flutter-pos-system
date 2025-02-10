import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';

List<List<CellData>> getAllFormattedFieldHeaders(FormattableModel? able) {
  return (able?.toList() ?? FormattableModel.values).map((able) => findFieldFormatter(able).getHeader()).toList();
}

List<List<List<CellData>>> getAllFormattedFieldData(FormattableModel? able) {
  return (able?.toList() ?? FormattableModel.values).map((able) => findFieldFormatter(able).getRows()).toList();
}

ModelFormatter<Repository, CellData> findFieldFormatter(FormattableModel able) {
  switch (able) {
    case FormattableModel.menu:
      return _MenuFormatter(Menu.instance, able.toParser());
    case FormattableModel.stock:
      return _StockFormatter(Stock.instance, able.toParser());
    case FormattableModel.quantities:
      return _QuantitiesFormatter(Quantities.instance, able.toParser());
    case FormattableModel.replenisher:
      return _ReplenisherFormatter(Replenisher.instance, able.toParser());
    case FormattableModel.orderAttr:
      return _OAFormatter(OrderAttributes.instance, able.toParser());
  }
}

class _MenuFormatter extends ModelFormatter<Menu, CellData> {
  const _MenuFormatter(super.target, super.parser);

  @override
  List<CellData> getHeader() => [
        CellData(string: S.menuCatalogNameLabel, isBold: true),
        CellData(string: S.menuProductNameLabel, isBold: true),
        CellData(string: S.menuProductPriceLabel, isBold: true),
        CellData(string: S.menuProductCostLabel, isBold: true),
        CellData(
          string: S.transitGSModelProductIngredientTitle,
          note: S.transitGSModelProductIngredientNote,
          isBold: true,
        ),
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

class _StockFormatter extends ModelFormatter<Stock, CellData> {
  const _StockFormatter(super.target, super.parser);

  @override
  List<CellData> getHeader() => [
        CellData(string: S.stockIngredientNameLabel, isBold: true),
        CellData(string: S.stockIngredientAmountLabel, isBold: true),
        CellData(string: S.stockIngredientAmountMaxLabel, isBold: true),
        CellData(string: S.stockIngredientRestockPriceLabel, isBold: true),
        CellData(string: S.stockIngredientRestockQuantityLabel, isBold: true),
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

class _QuantitiesFormatter extends ModelFormatter<Quantities, CellData> {
  const _QuantitiesFormatter(super.target, super.parser);

  @override
  List<CellData> getHeader() => [
        CellData(string: S.stockQuantityNameLabel, isBold: true),
        CellData(string: S.stockQuantityProportionLabel, note: S.stockQuantityProportionHelper, isBold: true),
      ];

  @override
  List<List<CellData>> getRows() => target.itemList
      .map((quantity) => [
            CellData(string: quantity.name),
            CellData(number: quantity.defaultProportion),
          ])
      .toList();
}

class _ReplenisherFormatter extends ModelFormatter<Replenisher, CellData> {
  const _ReplenisherFormatter(super.target, super.parser);

  @override
  List<CellData> getHeader() => [
        CellData(string: S.stockReplenishmentNameLabel, isBold: true),
        CellData(string: S.transitGSModelReplenishmentTitle, note: S.transitGSModelReplenishmentNote, isBold: true),
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

class _OAFormatter extends ModelFormatter<OrderAttributes, CellData> {
  const _OAFormatter(super.target, super.parser);

  @override
  List<CellData> getHeader() {
    final note = OrderAttributeMode.values
        .map((e) => '${S.orderAttributeModeName(e.name)} -  ${S.orderAttributeModeHelper(e.name)}')
        .join('\n');
    return <CellData>[
      CellData(string: S.orderAttributeNameLabel, isBold: true),
      CellData(string: S.orderAttributeModeDivider, note: note, isBold: true),
      CellData(string: S.transitGSModelAttributeOptionTitle, note: S.transitGSModelAttributeOptionNote, isBold: true),
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
