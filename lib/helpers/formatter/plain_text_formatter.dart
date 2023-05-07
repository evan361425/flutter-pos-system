import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';

const _reDig = r'-?\d+\.?\d*';
const _rePre = r'^';
const _rePost = r'$';

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
    if (line.startsWith('本菜單')) {
      return Formattable.menu;
    } else if (line.startsWith('本庫存')) {
      return Formattable.stock;
    } else if (line.endsWith('種份量')) {
      return Formattable.quantities;
    } else if (line.endsWith('種補貨方式')) {
      return Formattable.replenisher;
    } else if (line.endsWith('種顧客屬性')) {
      return Formattable.orderAttr;
    }

    return null;
  }
}

class _MenuTransformer extends ModelTransformer<Menu> {
  const _MenuTransformer(Menu target) : super(target);

  static const catalogTmp = r'第%num個種類叫做 %name';
  static const productTmp = r'第%num個產品叫做 %name，其售價為 %price 元，成本為 %cost 元';
  static const ingredientTmp = r'每份產品預設需要使用 %amount 個 %name';
  static const quantityTmp = r'%name（'
      '每份產品改成使用 %amount 個'
      '並調整產品售價 %price 元和'
      '成本 %cost 元）';

  @override
  List<String> getHeader() =>
      ['${target.length} 個產品種類', '${target.products.length} 個產品'];

  @override
  List<List<String>> getRows() {
    int catalogCount = 1;
    return [
      ['本菜單共有 ${target.length} 個產品種類、${target.products.length} 個產品。'],
      ...target.itemList.map<List<String>>((catalog) {
        int productCount = 1;
        final v = catalog.isEmpty ? '沒有設定產品' : '共有 ${catalog.length} 個產品';
        return [
          '${catalogTmp.f({'num': catalogCount++, 'name': catalog.name})}，$v。',
          ...catalog.itemList.map<String>((product) {
            String base = (productCount > 1 ? '\n' : '') +
                productTmp.f({
                  'num': productCount++,
                  'name': product.name,
                  'price': product.price,
                  'cost': product.cost,
                });
            if (product.isEmpty) {
              return '$base，它沒有設定任何成份。';
            }

            base = '$base，它的成份有 ${product.items.length} 種：'
                '${product.items.map((e) => e.name).join('、')}';

            final ingredients = product.items.map<String>((ingredient) {
              final ing = ingredientTmp.f({
                'amount': ingredient.amount,
                'name': ingredient.name,
              });
              if (ingredient.isEmpty) {
                return '$ing，無法做份量調整';
              }

              final quantities = ingredient.items
                  .map((quantity) => quantityTmp.f({
                        'name': quantity.name,
                        'amount': quantity.amount,
                        'price': quantity.additionalPrice,
                        'cost': quantity.additionalCost,
                      }))
                  .join('、');
              return '$ing，它還有 ${ingredient.items.length} 個不同份量：$quantities';
            }).join('；');
            return '$base。$ingredients。';
          }),
        ];
      })
    ];
  }

  @override
  List<List<String>> parseRows(List<List<Object?>> rows) {
    final reCatalog = RegExp(_rePre +
        catalogTmp.f({
          'num': r'\d+',
          'name': r'(?<name>[^，]+?)，',
        }));
    final reProduct = RegExp(_rePre +
        productTmp.f({
          'num': r'\d+',
          'name': r'(?<name>[^，]+?)',
          'price': '(?<price>$_reDig)',
          'cost': '(?<cost>$_reDig)',
        }));
    final reIngredient = RegExp(_rePre +
        ingredientTmp.f({
          'amount': '(?<amount>$_reDig)',
          'name': r'(?<name>[^，]+?)，',
        }));
    final reQuantity = RegExp(_rePre +
        quantityTmp.f({
          'name': r'(?<name>[^（]+?)',
          'amount': '(?<amount>$_reDig)',
          'price': '(?<price>$_reDig)',
          'cost': '(?<cost>$_reDig)',
        }));

    final lines = rows[0]
        .expand((e) => e.toString().split('。').map((e) => e.trim()))
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
  const _StockTransformer(Stock target) : super(target);

  static const baseTmp = r'第%num個成份叫做 %name，庫存現有 %amount 個';
  static const maxTmp = r'最大量有 %max 個。';

  @override
  List<String> getHeader() => ['${target.length} 種成份'];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    return [
      ['本庫存共有 ${target.length} 種成份'],
      ...target.itemList.map((ingredient) {
        final max = ingredient.totalAmount;
        final maxStr = max == null ? '' : '，${maxTmp.f({'max': max})}';
        return [
          baseTmp.f({
                'num': counter++,
                'name': ingredient.name,
                'amount': ingredient.currentAmount,
              }) +
              maxStr,
        ];
      })
    ];
  }

  @override
  List<List<String>> parseRows(List<List<Object?>> rows) {
    final reBase = RegExp(_rePre +
        baseTmp.f({
          'num': r'\d+',
          'name': r'(?<name>[^，]+?)',
          'amount': '(?<amount>$_reDig)',
        }));
    final reMax = RegExp(maxTmp.f({'max': '(?<max>$_reDig)'}) + _rePost);

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
  const _QuantitiesTransformer(Quantities target) : super(target);

  static const baseTmp = r'第%num種份量叫做 %name，'
      '預設會讓成分的份量乘以 %prop 倍。';

  @override
  List<String> getHeader() => ['${target.length} 種份量'];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    return [
      ['共設定 ${target.length} 種份量'],
      ...target.itemList.map((quantity) {
        return [
          baseTmp.f({
            'num': counter++,
            'name': quantity.name,
            'prop': quantity.defaultProportion,
          }),
        ];
      })
    ];
  }

  @override
  List<List<String>> parseRows(List<List<Object?>> rows) {
    final re = RegExp(_rePre +
        baseTmp.f({
          'num': r'\d+',
          'name': r'(?<name>[^，]+?)',
          'prop': '(?<prop>$_reDig)',
        }));

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
  const _ReplenisherTransformer(Replenisher target) : super(target);

  static const baseTmp = r'第%num種方式叫做 %name，';
  static const ingredientTmp = r'%name（%amount 個）';

  @override
  List<String> getHeader() => ['${target.length} 種補貨方式'];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    return [
      ['共設定 ${target.length} 種補貨方式'],
      ...target.itemList.map((repl) {
        final data = repl.ingredientData;
        final base = baseTmp.f({'num': counter++, 'name': repl.name});

        if (data.isEmpty) {
          return ['$base它並不會調整庫存。'];
        }
        final ing = data.entries
            .map((e) => ingredientTmp.f({
                  'name': e.key.name,
                  'amount': e.value,
                }))
            .join('、');
        return ['$base它會調整${data.length}種成份的庫存：$ing。'];
      })
    ];
  }

  @override
  List<List<String>> parseRows(List<List<Object?>> rows) {
    final reBase = RegExp(_rePre +
        baseTmp.f({
          'num': r'\d+',
          'name': r'(?<name>[^，]+?)',
        }));
    final reIngredient = RegExp(_rePre +
        ingredientTmp.f({
          'amount': '(?<amount>$_reDig)',
          'name': r'(?<name>[^（]+?)',
        }));

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
  const _OATransformer(OrderAttributes target) : super(target);

  static const baseTmp = r'第%num種屬性叫做 %name，屬於 %mode 類型。';

  @override
  List<String> getHeader() => ['${target.length} 種顧客屬性'];

  @override
  List<List<String>> getRows() {
    int counter = 1;
    return [
      ['共設定 ${target.length} 種顧客屬性'],
      ...target.itemList.map((attr) {
        final base = baseTmp.f({
          'num': counter++,
          'name': attr.name,
          'mode': S.orderAttributeModeNames(attr.mode.name),
        });
        if (attr.isEmpty) {
          return ['$base它並沒有設定選項。'];
        }

        final attrs = attr.itemList.map((e) {
          final info = [
            e.isDefault ? '預設' : '',
            e.modeValue == null ? '' : '選項的值為 ${e.modeValue}',
          ].where((e) => e.isNotEmpty).join('，');
          return info.isEmpty ? e.name : '${e.name}（$info）';
        }).join('、');

        return ['$base它有 ${attr.length} 個選項：$attrs'];
      })
    ];
  }

  @override
  List<List<String>> parseRows(List<List<Object?>> rows) {
    final reOA = RegExp(_rePre +
        baseTmp.f({
          'num': r'\d+',
          'name': r'(?<name>[^，]+?)',
          'mode': r'(?<mode>[^ ]+?)',
        }));

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
              if (infoStr.startsWith('預設')) {
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

extension _StringExtension on String {
  String f(Map<String, Object> params) {
    String result = this;
    for (final entry in params.entries) {
      result = result.replaceFirst('%${entry.key}', entry.value.toString());
    }
    return result;
  }
}
