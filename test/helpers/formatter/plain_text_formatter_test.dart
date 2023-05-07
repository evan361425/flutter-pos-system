import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/helpers/formatter/formatter.dart';
import 'package:possystem/helpers/formatter/plain_text_formatter.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/menu/product_ingredient.dart';
import 'package:possystem/models/menu/product_quantity.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/quantities.dart';
import 'package:possystem/models/repository/replenisher.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/models/stock/ingredient.dart';
import 'package:possystem/models/stock/quantity.dart';
import 'package:possystem/models/stock/replenishment.dart';
import 'package:possystem/settings/currency_setting.dart';

import '../../test_helpers/translator.dart';

void main() {
  group('Plain Text Formatter', () {
    List<FormattedItem<T>> format<T extends Model>(
      Formattable able,
      String expected,
    ) {
      const formatter = PlainTextFormatter();
      final text =
          formatter.getRows(able).map((row) => row.join('\n')).join('\n\n');
      expect(text, equals(expected));

      final lines = text.trim().split('\n');

      final guessed = formatter.whichFormattable(lines.removeAt(0));
      return formatter.format<T>(guessed!, [lines]);
    }

    test('menu', () {
      final menu = Menu();
      final stock = Stock();
      final quantities = Quantities();

      final i1 = Ingredient(id: 'i1', name: 'i1');
      final i2 = Ingredient(id: 'i2', name: 'i2');
      final i5 = Ingredient(id: 'i5', name: 'i5');
      final q1 = Quantity(id: 'q1', name: 'q1');
      final q2 = Quantity(id: 'q2', name: 'q2');
      stock.replaceItems({'i1': i1, 'i2': i2, 'i5': i5});
      quantities.replaceItems({'q1': q1, 'q2': q2});
      menu.replaceItems({
        'A': Catalog(id: 'A', name: 'A', products: {
          'pA': Product(id: 'pA', name: 'pA', index: 1, price: 2, cost: 2),
          'pA2': Product(id: 'pA2', name: 'pA2', index: 2, ingredients: {
            'pAi1': ProductIngredient(
              id: 'pAi1',
              amount: 2,
              ingredient: i1,
              quantities: {
                'pAq1': ProductQuantity(
                  id: 'pAq1',
                  amount: 2,
                  additionalCost: 2,
                  additionalPrice: 2,
                  quantity: q1,
                ),
                'pAq2': ProductQuantity(
                  id: 'pAq2',
                  amount: 5,
                  additionalCost: -5,
                  additionalPrice: -5,
                  quantity: q2,
                ),
              },
            ),
            'pAi2': ProductIngredient(id: 'pAi2', ingredient: i2),
            'pAi3': ProductIngredient(
              id: 'pAi3',
              ingredient: i5,
              quantities: {
                'pAq2': ProductQuantity(
                  id: 'pAq2',
                  amount: 1,
                  additionalCost: 1,
                  additionalPrice: 1,
                  quantity: q1,
                ),
              },
            ),
          }),
          'pA3': Product(id: 'pA3', name: 'pA3', index: 3),
        }),
        'B': Catalog(id: 'B', name: 'B'),
        'C': Catalog(id: 'C', name: 'C', products: {
          'pA4': Product(id: 'pA4', name: 'pA4', index: 4),
        }),
      });
      for (var c in menu.items) {
        c.prepareItem();
        for (var p in c.items) {
          p.prepareItem();
        }
      }

      final items = format<Product>(
        Formattable.menu,
        '本菜單共有 3 個產品種類、4 個產品。\n'
        '\n'
        '第1個種類叫做 A，共有 3 個產品。\n'
        '第1個產品叫做 pA，其售價為 2 元，成本為 2 元，它沒有設定任何成份。\n'
        '\n'
        '第2個產品叫做 pA2，其售價為 0 元，成本為 0 元，它的成份有 3 種：i1、i2、i5。'
        '每份產品預設需要使用 2 個 i1，它還有 2 個不同份量：'
        'q1（每份產品改成使用 2 個並調整產品售價 2 元和成本 2 元）、'
        'q2（每份產品改成使用 5 個並調整產品售價 -5 元和成本 -5 元）；'
        '每份產品預設需要使用 0 個 i2，無法做份量調整；'
        '每份產品預設需要使用 0 個 i5，它還有 1 個不同份量：'
        'q1（每份產品改成使用 1 個並調整產品售價 1 元和成本 1 元）。\n'
        '\n'
        '第3個產品叫做 pA3，其售價為 0 元，成本為 0 元，它沒有設定任何成份。\n'
        '\n'
        '第2個種類叫做 B，沒有設定產品。\n'
        '\n'
        '第3個種類叫做 C，共有 1 個產品。\n'
        '第1個產品叫做 pA4，其售價為 0 元，成本為 0 元，它沒有設定任何成份。',
      );

      expect(
        items.map((e) {
          final map = e.item?.toObject().toMap();
          map?.remove('createdAt');
          return map.toString();
        }).toList(),
        equals(menu.products.map((e) {
          final map = e.toObject().toMap();
          map.remove('createdAt');
          return map.toString();
        }).toList()),
      );
    });

    test('stock', () {
      final stock = Stock();
      stock.replaceItems({
        'i1': Ingredient(id: 'i1', name: 'i1'),
        'i2': Ingredient(id: 'i2', name: 'i2', currentAmount: 1.0),
        'i3': Ingredient(
          id: 'i3',
          name: 'i3',
          currentAmount: 1.0,
          totalAmount: 2.0,
        ),
      });

      final items = format<Ingredient>(
        Formattable.stock,
        '本庫存共有 3 種成份\n'
        '\n'
        '第1個成份叫做 i1，庫存現有 0.0 個\n'
        '\n'
        '第2個成份叫做 i2，庫存現有 1.0 個\n'
        '\n'
        '第3個成份叫做 i3，庫存現有 1.0 個，最大量有 2.0 個。',
      );

      expect(
        items.map((e) => e.item?.toObject().toMap().toString()).toList(),
        equals(
            stock.items.map((e) => e.toObject().toMap().toString()).toList()),
      );
    });

    test('quantities', () {
      final quantities = Quantities();
      quantities.replaceItems({
        'q1': Quantity(id: 'q1', name: 'q1'),
        'q2': Quantity(id: 'q2', name: 'q2', defaultProportion: 2),
        'q3': Quantity(id: 'q3', name: 'q3', defaultProportion: 0),
        'q4': Quantity(id: 'q4', name: 'q4', defaultProportion: 0.5),
      });

      final items = format<Quantity>(
        Formattable.quantities,
        '共設定 4 種份量\n'
        '\n'
        '第1種份量叫做 q1，預設會讓成分的份量乘以 1 倍。\n'
        '\n'
        '第2種份量叫做 q2，預設會讓成分的份量乘以 2 倍。\n'
        '\n'
        '第3種份量叫做 q3，預設會讓成分的份量乘以 0 倍。\n'
        '\n'
        '第4種份量叫做 q4，預設會讓成分的份量乘以 0.5 倍。',
      );

      expect(
        items.map((e) => e.item?.toObject().toMap().toString()).toList(),
        equals(quantities.items.map((e) {
          return e.toObject().toMap().toString();
        }).toList()),
      );
    });

    test('replenisher', () {
      final stock = Stock();
      stock.replaceItems({
        'i1': Ingredient(id: 'i1', name: 'i1'),
        'i2': Ingredient(id: 'i2', name: 'i2'),
        'i3': Ingredient(id: 'i3', name: 'i3'),
      });

      final replenisher = Replenisher();
      replenisher.replaceItems({
        'r1': Replenishment(id: 'r1', name: 'r1'),
        'r2': Replenishment(id: 'r2', name: 'r2', data: {
          'i1': 20,
          'i2': -30,
          'i3': 0.5,
        }),
      });

      final items = format<Replenishment>(
        Formattable.replenisher,
        '共設定 2 種補貨方式\n'
        '\n'
        '第1種方式叫做 r1，它並不會調整庫存。\n'
        '\n'
        '第2種方式叫做 r2，它會調整3種成份的庫存：i1（20 個）、i2（-30 個）、i3（0.5 個）。',
      );

      expect(
        items.map((e) => e.item?.toObject().toMap().toString()).toList(),
        equals(replenisher.items.map((e) {
          return e.toObject().toMap().toString();
        }).toList()),
      );
    });

    test('order attributes', () {
      CurrencySetting().isInt = true;
      final attrs = OrderAttributes();
      attrs.replaceItems({
        'c1': OrderAttribute(
          id: 'c1',
          name: 'c1',
          index: 1,
          mode: OrderAttributeMode.changePrice,
          options: {
            'o1': OrderAttributeOption(id: 'o1', name: 'o1', index: 1),
            'o2': OrderAttributeOption(
              id: 'o2',
              name: 'o2',
              index: 2,
              isDefault: true,
            ),
            'o3': OrderAttributeOption(
              id: 'o3',
              name: 'o3',
              index: 3,
              modeValue: 20,
            ),
          },
        ),
        'c2': OrderAttribute(id: 'c2', name: 'c2', index: 2),
        'c3': OrderAttribute(
          id: 'c3',
          name: 'c3',
          index: 3,
          mode: OrderAttributeMode.changeDiscount,
          options: {
            'o1': OrderAttributeOption(
              id: 'o1',
              name: 'o1',
              isDefault: true,
              modeValue: 20,
              index: 1,
            ),
            'o2': OrderAttributeOption(
              id: 'o2',
              name: 'o2',
              modeValue: 0,
              index: 2,
            ),
          },
        ),
      });
      for (var attr in attrs.items) {
        attr.prepareItem();
      }

      final items = format<OrderAttribute>(
        Formattable.orderAttr,
        '共設定 3 種顧客屬性\n'
        '\n'
        '第1種屬性叫做 c1，屬於 變價 類型。它有 3 個選項：'
        'o1、o2（預設）、o3（選項的值為 20）\n'
        '\n'
        '第2種屬性叫做 c2，屬於 一般 類型。它並沒有設定選項。\n'
        '\n'
        '第3種屬性叫做 c3，屬於 折扣 類型。它有 2 個選項：'
        'o1（預設，選項的值為 20）、o2（選項的值為 0）',
      );

      expect(
        items.map((e) => e.item?.toObject().toMap().toString()).toList(),
        equals(attrs.items.map((e) => '${e.toObject().toMap()}').toList()),
      );
    });

    test('unable to found which formattable', () {
      const formatter = PlainTextFormatter();
      expect(formatter.whichFormattable('some-text'), equals(null));
    });

    setUpAll(() {
      initializeTranslator();
    });
  });
}
