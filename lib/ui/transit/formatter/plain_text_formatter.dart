import 'package:intl/intl.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/transit/formatter/formatter.dart';

const _reDig = r' *-?\d+\.?\d*';
const _reInt = r'[0-9 ]+';
const _rePre = r'^';

ModelFormatter<Repository, String> findPlainTextFormatter(FormattableModel able) {
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

FormattableModel? findPlainTextFormattable(String line) {
  if (line.startsWith(S.transitFormatTextMenuHeaderPrefix)) {
    return FormattableModel.menu;
  } else if (line.startsWith(S.transitFormatTextStockHeaderPrefix)) {
    return FormattableModel.stock;
  } else if (line.endsWith(S.transitFormatTextQuantitiesHeaderSuffix)) {
    return FormattableModel.quantities;
  } else if (line.endsWith(S.transitFormatTextReplenisherHeaderSuffix)) {
    return FormattableModel.replenisher;
  } else if (line.endsWith(S.transitFormatTextOaHeaderSuffix)) {
    return FormattableModel.orderAttr;
  }

  return null;
}

class _MenuFormatter extends ModelFormatter<Menu, String> {
  const _MenuFormatter(super.target, super.parser);

  static const ingredientDelimiter = '；';
  static const quantityPrefix = '：';
  static const quantityDelimiter = '、';

  @override
  List<String> getHeader() =>
      [S.transitFormatTextMenuMetaCatalog(target.length), S.transitFormatTextMenuMetaProduct(target.products.length)];

  @override
  List<List<String>> getRows() {
    int catalogCount = 1;
    return [
      [S.transitFormatTextMenuHeader(target.length, target.products.length)],
      ...target.itemList.map<List<String>>((catalog) {
        int productCount = 1;
        final nf = NumberFormat.decimalPattern(S.localeName);
        return [
          S.transitFormatTextMenuCatalog(
            (catalogCount++).toString(),
            catalog.name,
            S.transitFormatTextMenuCatalogDetails(catalog.length),
          ),
          for (final product in catalog.itemList)
            S.transitFormatTextMenuProduct(
              (productCount++).toString(),
              product.name,
              product.price.toCurrency(),
              product.cost.toCurrency(),
              S.transitFormatTextMenuProductDetails(
                product.items.length,
                product.items.map((e) => e.name).join('、'),
                product.items
                    .map<String>(
                      (ingredient) => S.transitFormatTextMenuIngredient(
                        nf.format(ingredient.amount),
                        ingredient.name,
                        S.transitFormatTextMenuIngredientDetails(
                          ingredient.items.length,
                          quantityPrefix +
                              ingredient.items
                                  .map((quantity) => '${quantity.name}（${S.transitFormatTextMenuQuantity(
                                        nf.format(quantity.amount),
                                        quantity.additionalPrice.toCurrency(),
                                        quantity.additionalCost.toCurrency(),
                                      )}）')
                                  .join(quantityDelimiter),
                        ),
                      ),
                    )
                    .join(ingredientDelimiter),
              ),
            ),
        ];
      })
    ];
  }

  @override
  List<List<String>> transformRows(List<List<String>> rows) {
    final reCatalog = RegExp(
      _rePre +
          S.transitFormatTextMenuCatalog(
            _reInt,
            r'(?<name>.+)',
            r'.*',
          ),
    );
    final reProduct = RegExp(
      _rePre +
          S
              .transitFormatTextMenuProduct(
                _reInt,
                r'(?<name>.+)',
                '(?<price>$_reDig)',
                '(?<cost>$_reDig)',
                r'.*',
              )
              .replaceAll(r'$', r'\$'),
    );
    final reIngredient = RegExp(
      S.transitFormatTextMenuIngredient(
        '(?<amount>$_reDig)',
        r'(?<name>.+?)',
        r'.*',
      ),
    );
    final reQuantity = RegExp(
      _rePre +
          r'(?<name>.+)（' + // hard coded naming pattern
          S
              .transitFormatTextMenuQuantity(
                '(?<amount>$_reDig)',
                '(?<price>$_reDig)',
                '(?<cost>$_reDig)',
              )
              .replaceAll(r'$', r'\$'),
    );

    final lines = rows[0]
        .expand((e) => e.split('\n').map((e) => e.trim())) // split by line
        .where((e) => e.isNotEmpty);
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

      final ingSplit = line.split(ingredientDelimiter);
      String ingredients = '';
      foundProduct = false;
      for (final ing in ingSplit) {
        int quaStartIndex = ing.indexOf(quantityPrefix);
        if (quaStartIndex == -1) quaStartIndex = ing.length;

        match = reIngredient.firstMatch(ing.substring(0, quaStartIndex));
        if (match != null) {
          ingredients = '$ingredients\n- ${match.namedGroup('name')!},'
              '${match.namedGroup('amount')!}';
        }
        if (quaStartIndex == ing.length) continue;

        final quaSplit = ing.substring(quaStartIndex + 1).split(quantityDelimiter);
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

class _StockFormatter extends ModelFormatter<Stock, String> {
  const _StockFormatter(super.target, super.parser);

  @override
  List<String> getHeader() => [S.transitFormatTextStockMetaIngredient(target.length)];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    final nf = NumberFormat.decimalPattern(S.localeName);
    return [
      [S.transitFormatTextStockHeader(target.length)],
      [
        for (final ingredient in target.itemList)
          S.transitFormatTextStockIngredient(
            (counter++).toString(),
            ingredient.name,
            nf.format(ingredient.currentAmount),
            S.transitFormatTextStockIngredientMaxAmount(
                  ingredient.totalAmount == null ? 0 : 1,
                  nf.format(ingredient.totalAmount ?? 0),
                ) +
                S.transitFormatTextStockIngredientRestockPrice(
                  ingredient.restockPrice == null ? 0 : 1,
                  nf.format(ingredient.restockQuantity),
                  nf.format(ingredient.restockPrice ?? 0),
                ),
          ),
      ],
    ];
  }

  @override
  List<List<String>> transformRows(List<List<Object?>> rows) {
    final reBase = RegExp(_rePre +
        S.transitFormatTextStockIngredient(
          _reInt,
          r'(?<name>.+?)',
          '(?<amount>$_reDig)',
          r'(?<details>.*)',
        ));
    final reMax = RegExp(S.transitFormatTextStockIngredientMaxAmount(1, '(?<max>$_reDig)'));
    final reRestock = RegExp(
      S.transitFormatTextStockIngredientRestockPrice(1, '(?<q>$_reDig)', '(?<p>$_reDig)').replaceAll(r'$', r'\$'),
    );

    final result = <List<String>>[];
    for (final line in rows[0]) {
      final base = reBase.firstMatch(line.toString());
      if (base != null) {
        final parsed = [base.namedGroup('name')!, base.namedGroup('amount')!];
        final details = base.namedGroup('details');

        if (details != null && details.isNotEmpty) {
          final max = reMax.firstMatch(details);
          parsed.add(max != null ? max.namedGroup('max')! : 'null');

          final restock = reRestock.firstMatch(details);
          if (restock != null) {
            parsed.add(restock.namedGroup('p')!);
            parsed.add(restock.namedGroup('q')!);
          }
        }
        result.add(parsed);
      }
    }

    return result;
  }
}

class _QuantitiesFormatter extends ModelFormatter<Quantities, String> {
  const _QuantitiesFormatter(super.target, super.parser);

  @override
  List<String> getHeader() => [S.transitFormatTextQuantitiesMetaQuantity(target.length)];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    final nf = NumberFormat.decimalPattern(S.localeName);
    return [
      [S.transitFormatTextQuantitiesHeader(target.length)],
      [
        for (final quantity in target.itemList)
          S.transitFormatTextQuantitiesQuantity(
            (counter++).toString(),
            quantity.name,
            nf.format(quantity.defaultProportion),
          ),
      ]
    ];
  }

  @override
  List<List<String>> transformRows(List<List<Object?>> rows) {
    final re = RegExp(
      _rePre +
          S.transitFormatTextQuantitiesQuantity(
            _reInt,
            r'(?<name>.+?)',
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

class _ReplenisherFormatter extends ModelFormatter<Replenisher, String> {
  const _ReplenisherFormatter(super.target, super.parser);

  static const ingredientDelimiter = '：';

  @override
  List<String> getHeader() => [S.transitFormatTextReplenisherMetaReplenishment(target.length)];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    final nf = NumberFormat.decimalPattern(S.localeName);
    return [
      [S.transitFormatTextReplenisherHeader(target.length)],
      target.itemList.map((repl) {
        String d = repl.ingredientData.entries.map((e) => '${e.key.name}（${nf.format(e.value)}）').join('、');
        d = d.isEmpty ? '' : ingredientDelimiter + d;
        return S.transitFormatTextReplenisherReplenishment(
          (counter++).toString(),
          repl.name,
          S.transitFormatTextReplenisherReplenishmentDetails(repl.ingredientData.length) + d,
        );
      }).toList(),
    ];
  }

  @override
  List<List<String>> transformRows(List<List<Object?>> rows) {
    final reBase = RegExp(
      _rePre +
          S.transitFormatTextReplenisherReplenishment(
            _reInt,
            r'(?<name>.+?)',
            '.*',
          ),
    );
    final reIngredient = RegExp('$_rePre(?<name>.*)（(?<amount>$_reDig)）');

    final result = <List<String>>[];
    for (final line in rows[0]) {
      final lineSplit = line.toString().split(ingredientDelimiter);
      final baseMatch = reBase.firstMatch(lineSplit[0]);
      if (baseMatch != null) {
        String ingredients = '';
        if (lineSplit.length > 1) {
          final lineIng = lineSplit[1].replaceFirst(RegExp(r'[^）]*$'), '');
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

class _OAFormatter extends ModelFormatter<OrderAttributes, String> {
  const _OAFormatter(super.target, super.parser);

  @override
  List<String> getHeader() => [S.transitFormatTextOaMetaOa(target.length)];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    return [
      [S.transitFormatTextOaHeader(target.length)],
      target.itemList.map((attr) {
        String details = attr.itemList.map((e) {
          final details = [
            e.isDefault ? S.transitFormatTextOaDefaultOption : '',
            e.modeValue == null ? '' : S.transitFormatTextOaModeValue(e.modeValue!),
          ].where((e) => e.isNotEmpty).join('，');
          return details.isEmpty ? e.name : '${e.name}（$details）';
        }).join('、');
        details = details.isEmpty ? '' : '：$details';

        return S.transitFormatTextOaOa(
          (counter++).toString(),
          attr.name,
          S.orderAttributeModeName(attr.mode.name),
          S.transitFormatTextOaOaDetails(attr.length) + details,
        );
      }).toList(),
    ];
  }

  @override
  List<List<String>> transformRows(List<List<Object?>> rows) {
    final reOA = RegExp(_rePre +
        S.transitFormatTextOaOa(
          _reInt,
          r'(?<name>.+?)',
          r'(?<mode>.+)',
          '.*',
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
              if (infoStr.startsWith(S.transitFormatTextOaDefaultOption)) {
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
