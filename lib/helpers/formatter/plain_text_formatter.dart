import 'package:intl/intl.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';

const _reDig = r'-?\d+\.?\d*';
const _rePre = r'^';

class PlainTextFormatter extends Formatter<String> {
  const PlainTextFormatter();

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

  Formattable? whichFormattable(String line) {
    if (line.startsWith(S.transitPTFormatModelMenuHeaderPrefix)) {
      return Formattable.menu;
    } else if (line.startsWith(S.transitPTFormatModelStockHeaderPrefix)) {
      return Formattable.stock;
    } else if (line.endsWith(S.transitPTFormatModelQuantitiesHeaderSuffix)) {
      return Formattable.quantities;
    } else if (line.endsWith(S.transitPTFormatModelReplenisherHeaderSuffix)) {
      return Formattable.replenisher;
    } else if (line.endsWith(S.transitPTFormatModelOaHeaderSuffix)) {
      return Formattable.orderAttr;
    }

    return null;
  }
}

class _MenuTransformer extends ModelTransformer<Menu> {
  const _MenuTransformer(super.target);

  @override
  List<String> getHeader() => [
        S.transitPTFormatModelMenuMetaCatalog(target.length),
        S.transitPTFormatModelMenuMetaProduct(target.products.length)
      ];

  @override
  List<List<String>> getRows() {
    int catalogCount = 1;
    return [
      [S.transitPTFormatModelMenuHeader(target.length, target.products.length)],
      ...target.itemList.map<List<String>>((catalog) {
        int productCount = 1;
        final nf = NumberFormat.decimalPattern(S.localeName);
        return [
          S.transitPTFormatModelMenuCatalog(
            (catalogCount++).toString(),
            catalog.name,
            S.transitPTFormatModelMenuCatalogDetails(catalog.length),
          ),
          for (final product in catalog.itemList)
            S.transitPTFormatModelMenuProduct(
              (productCount++).toString(),
              product.name,
              product.price.toCurrency(),
              product.cost.toCurrency(),
              S.transitPTFormatModelMenuProductDetails(
                product.items.length,
                product.items.map((e) => e.name).join('、'),
                product.items
                    .map<String>(
                      (ingredient) => S.transitPTFormatModelMenuIngredient(
                        nf.format(ingredient.amount),
                        ingredient.name,
                        S.transitPTFormatModelMenuIngredientDetails(
                          ingredient.items.length,
                          ingredient.items
                              .map((quantity) => '${quantity.name}（${S.transitPTFormatModelMenuQuantity(
                                    nf.format(quantity.amount),
                                    quantity.additionalPrice.toCurrency(),
                                    quantity.additionalCost.toCurrency(),
                                  )}）')
                              .join('、'),
                        ),
                      ),
                    )
                    .join('；'),
              ),
            ),
        ];
      })
    ];
  }

  @override
  List<List<String>> parseRows(List<List<Object?>> rows) {
    final reCatalog = RegExp(
      _rePre +
          S.transitPTFormatModelMenuCatalog(
            r'\d+',
            r'(?<name>[^，]+?)',
            '',
          ),
    );
    final reProduct = RegExp(
      _rePre +
          S.transitPTFormatModelMenuProduct(
            r'\d+',
            r'(?<name>[^，]+?)',
            '(?<price>$_reDig)',
            '(?<cost>$_reDig)',
            '',
          ),
    );
    final reIngredient = RegExp(
      _rePre +
          S.transitPTFormatModelMenuIngredient(
            '(?<amount>$_reDig)',
            r'(?<name>[^，]+?)',
            '',
          ),
    );
    final reQuantity = RegExp(
      _rePre +
          r'(?<name>[^（]+?)（' +
          S.transitPTFormatModelMenuQuantity(
            '(?<amount>$_reDig)',
            '(?<price>$_reDig)',
            '(?<cost>$_reDig)',
          ),
    );

    final lines = rows[0].expand((e) => e.toString().split('。').map((e) => e.trim())).where((e) => e.isNotEmpty);
    final result = <List<String>>[];
    String catalog = '', product = '', price = '', cost = '';
    bool foundProduct = false;
    void addProductIfNeed() {
      if (foundProduct) {
        result.add([catalog, product, price, cost]);
        foundProduct = false;
      }
    }

    for (final line in lines) {
      RegExpMatch? match = reCatalog.firstMatch(line);
      if (match != null) {
        addProductIfNeed();
        catalog = match.namedGroup('name')!;
        continue;
      }

      match = reProduct.firstMatch(line);
      if (match != null) {
        addProductIfNeed();
        product = match.namedGroup('name')!;
        price = match.namedGroup('price')!;
        cost = match.namedGroup('cost')!;
        foundProduct = true;
        continue;
      }

      final ingSplit = line.split('；');
      String ingredients = '';
      foundProduct = false;
      for (final ing in ingSplit) {
        final ingSplit = ing.split('：');

        match = reIngredient.firstMatch(ingSplit[0]);
        if (match != null) {
          ingredients = '$ingredients\n- ${match.namedGroup('name')!},'
              '${match.namedGroup('amount')!}';
        }

        if (ingSplit.length == 1) continue;
        final quaSplit = ingSplit[1].split('、');

        for (final qua in quaSplit) {
          match = reQuantity.firstMatch(qua);
          if (match != null) {
            ingredients = '$ingredients\n+ ${match.namedGroup('name')!},'
                '${match.namedGroup('amount')!},'
                '${match.namedGroup('price')!},'
                '${match.namedGroup('cost')!},';
          }
        }
      }

      result.add([catalog, product, price, cost, ingredients]);
    }

    addProductIfNeed();
    return result;
  }
}

class _StockTransformer extends ModelTransformer<Stock> {
  const _StockTransformer(super.target);

  @override
  List<String> getHeader() => [S.transitPTFormatModelStockMetaIngredient(target.length)];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    final nf = NumberFormat.decimalPattern(S.localeName);
    return [
      [S.transitPTFormatModelStockHeader(target.length)],
      for (final ingredient in target.itemList)
        [
          S.transitPTFormatModelStockIngredient(
            (counter++).toString(),
            ingredient.name,
            nf.format(ingredient.currentAmount),
            S.transitPTFormatModelStockIngredientDetails(
              ingredient.totalAmount == null ? 0 : 1,
              nf.format(ingredient.totalAmount ?? 0),
            ),
          ),
        ],
    ];
  }

  @override
  List<List<String>> parseRows(List<List<Object?>> rows) {
    final reBase = RegExp(_rePre +
        S.transitPTFormatModelStockIngredient(
          r'\d+',
          r'(?<name>[^，]+?)',
          '(?<amount>$_reDig)',
          '',
        ));
    final reMax = RegExp(S.transitPTFormatModelStockIngredientDetails(1, '(?<max>$_reDig)'));

    final result = <List<String>>[];
    for (final line in rows[0]) {
      final base = reBase.firstMatch(line.toString());
      final max = reMax.firstMatch(line.toString());
      if (base != null) {
        result.add([
          base.namedGroup('name')!,
          base.namedGroup('amount')!,
          max?.namedGroup('max') ?? '',
        ]);
      }
    }

    return result;
  }
}

class _QuantitiesTransformer extends ModelTransformer<Quantities> {
  const _QuantitiesTransformer(super.target);

  @override
  List<String> getHeader() => [S.transitPTFormatModelQuantitiesMetaQuantity(target.length)];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    final nf = NumberFormat.decimalPattern(S.localeName);
    return [
      [S.transitPTFormatModelQuantitiesHeader(target.length)],
      [
        for (final quantity in target.itemList)
          S.transitPTFormatModelQuantitiesQuantity(
            (counter++).toString(),
            quantity.name,
            nf.format(quantity.defaultProportion),
          ),
      ]
    ];
  }

  @override
  List<List<String>> parseRows(List<List<Object?>> rows) {
    final re = RegExp(
      _rePre +
          S.transitPTFormatModelQuantitiesQuantity(
            r'\d+',
            r'(?<name>[^，]+?)',
            '(?<prop>$_reDig)',
          ),
    );

    final result = <List<String>>[];
    for (final line in rows[0]) {
      final match = re.firstMatch(line.toString());
      if (match != null) {
        result.add([
          match.namedGroup('name')!,
          match.namedGroup('prop')!,
        ]);
      }
    }

    return result;
  }
}

class _ReplenisherTransformer extends ModelTransformer<Replenisher> {
  const _ReplenisherTransformer(super.target);

  @override
  List<String> getHeader() => [S.transitPTFormatModelReplenisherMetaReplenishment(target.length)];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    final nf = NumberFormat.decimalPattern(S.localeName);
    return [
      [S.transitPTFormatModelReplenisherHeader(target.length)],
      [
        for (final repl in target.itemList)
          S.transitPTFormatModelReplenisherReplenishment(
            (counter++).toString(),
            repl.name,
            S.transitPTFormatModelReplenisherReplenishmentDetails(
              repl.ingredientData.length,
              repl.ingredientData.entries.map((e) => '${e.key.name}（${nf.format(e.value)}）').join('、'),
            ),
          ),
      ],
    ];
  }

  @override
  List<List<String>> parseRows(List<List<Object?>> rows) {
    final reBase = RegExp(
      _rePre +
          S.transitPTFormatModelReplenisherReplenishment(
            r'\d+',
            r'(?<name>[^，]+?)',
            '',
          ),
    );
    final reIngredient = RegExp(_rePre + r'(?<name>[^（]+?)（(?<amount>$_reDig)）');

    final result = <List<String>>[];
    for (final line in rows[0]) {
      final lineSplit = line.toString().split('：');
      final baseMatch = reBase.firstMatch(lineSplit[0]);
      if (baseMatch != null) {
        String ingredients = '';
        if (lineSplit.length > 1) {
          final lineIng = lineSplit[1].replaceFirst(RegExp(r'。?$'), '');
          for (final ing in lineIng.split('、')) {
            final match = reIngredient.firstMatch(ing);
            if (match != null) {
              ingredients = '$ingredients\n- ${match.namedGroup('name')!},'
                  '${match.namedGroup('amount')!}';
            }
          }
        }

        result.add([baseMatch.namedGroup('name')!, ingredients]);
      }
    }

    return result;
  }
}

class _OATransformer extends ModelTransformer<OrderAttributes> {
  const _OATransformer(super.target);

  @override
  List<String> getHeader() => [S.transitPTFormatModelOaMetaOa(target.length)];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    return [
      [S.transitPTFormatModelOaHeader(target.length)],
      [
        for (final attr in target.itemList)
          S.transitPTFormatModelOaOa(
            (counter++).toString(),
            attr.name,
            S.orderAttributeModeName(attr.mode.name),
            S.transitPTFormatModelOaOaDetails(
              attr.length,
              attr.itemList
                  .map((e) => '${e.name}（${[
                        e.isDefault ? S.transitPTFormatModelOaDefaultOption : '',
                        e.modeValue == null ? '' : S.transitPTFormatModelOaModeValue(e.modeValue!),
                      ].where((e) => e.isNotEmpty).join('，')}）')
                  .join('、'),
            ),
          ),
      ],
    ];
  }

  @override
  List<List<String>> parseRows(List<List<Object?>> rows) {
    final reOA = RegExp(_rePre +
        S.transitPTFormatModelOaOa(
          r'\d+',
          r'(?<name>[^，]+?)',
          r'(?<mode>[^ ]+?)',
          '',
        ));

    final result = <List<String>>[];
    for (final line in rows[0]) {
      final lineSplit = line.toString().split('：');
      final oaMatch = reOA.firstMatch(lineSplit[0]);
      if (oaMatch != null) {
        String options = '';
        if (lineSplit.length > 1) {
          for (final opt in lineSplit[1].split('、')) {
            final infoIdx = opt.indexOf('（');
            final name = infoIdx == -1 ? opt : opt.substring(0, infoIdx);
            String info = 'false';
            if (infoIdx != -1) {
              final infoStr = opt.substring(infoIdx + 1, opt.length - 1);
              if (infoStr.startsWith(S.transitPTFormatModelOaDefaultOption)) {
                info = 'true';
              }
              final v = RegExp(_reDig).firstMatch(infoStr)?.group(0) ?? '';
              info = '$info,$v';
            }
            options = '$options\n- $name,$info';
          }
        }

        result.add([
          oaMatch.namedGroup('name')!,
          oaMatch.namedGroup('mode')!,
          options,
        ]);
      }
    }

    return result;
  }
}
