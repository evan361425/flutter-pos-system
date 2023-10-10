import 'dart:convert';

import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:sqflite/sqflite.dart' show Database, Sqflite;

/// Helper to migrate DB schema from legacy.
final dbMigrationActions = <int, Future<void> Function(Database)>{
  6: _convertCustomerSettingToOrderAttribute,
  8: _makeOrderMoreEasyToAnalysis,
};

/// Convert customer_setting to order_attribute and using sqlite to store it.
Future<void> _convertCustomerSettingToOrderAttribute(
  Database db, {
  bool withLegacy = true,
  bool withOrder = true,
}) async {
  const step = 100;
  // convert CustomerSettings to OrderAttributes
  if (withLegacy) {
    final legacy = CustomerSettings();
    await legacy.initialize();
    for (final setting in legacy.items) {
      final attr = OrderAttribute.fromObject(setting.toObject());
      await OrderAttributes.instance.addItem(attr);
    }
    Log.ger('6', 'db_migration_action',
        '${legacy.length} to ${OrderAttributes.instance.length}');
  }

  if (!withOrder) return;

  // convert order to new format
  final totalCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM `order`')) ??
      0;
  final count = (totalCount / step).ceil();
  Log.ger('6', 'db_migration_action', '$totalCount orders');

  Map<String, String> dbParseCombination(String? value) {
    value = value ?? '';
    return {
      for (final item in value
          .split(',')
          .where((e) => e.isNotEmpty)
          .map((e) => e.split(':')))
        item[0]: item[1]
    };
  }

  for (var i = 0; i < count; i++) {
    final result = await db.rawQuery('SELECT o.id, csc.combination '
        'FROM `order` as o '
        'LEFT JOIN customer_setting_combinations AS csc '
        'ON o.customerSettingCombinationId = csc.id '
        'ORDER BY o.id ASC '
        'LIMIT $step OFFSET ${i * step}');
    Log.out('start $i - ${result.length}', 'db_migration_action_6');
    await Future.wait([
      for (var item in result)
        db.update(
          'order',
          {
            'encodedAttributes':
                jsonEncode(dbParseCombination(item['combination'] as String?)
                    .entries
                    .map((e) {
                      final attr = OrderAttributes.instance.getItem(e.key);
                      final opt = attr?.getItem(e.value);
                      if (opt == null) return null;
                      return OrderSelectedAttributeObject.fromModel(opt);
                    })
                    .where((e) => e != null)
                    .map<Map<String, Object?>>((e) => e!.toMap())
                    .toList())
          },
          where: 'id = ?',
          whereArgs: [item['id']],
        )
    ]);
    Log.out('done', 'db_migration_action_6');
  }

  await db.delete('order_stash');
  Log.out('clear stash', 'db_migration_action_6');
}

/// Formatting order structure and make it easy to analysis.
Future<void> _makeOrderMoreEasyToAnalysis(Database db) async {
  const limit = 100;

  Future<void> exec(Map<String, Object?> row) async {
    final price = row['totalPrice'] as num? ?? 0;
    final productsPrice = row['productsPrice'] as num? ?? price;
    final createdAt = row['createdAt'] as int;
    final prods = jsonDecode(row['encodedProducts'] as String) as List<dynamic>;
    final attrs = jsonDecode(row['encodedAttributes'] as String? ?? '[]')
        as List<dynamic>;

    final cost = prods.fold<num>(0, (v, e) => v + (e['cost'] as num? ?? 0));
    final count = prods.fold<int>(0, (v, e) => v + (e['count'] as int));

    await db.transaction((txn) async {
      final orderId = await txn.insert('order_records', {
        'paid': row['paid'],
        'price': price,
        'cost': cost,
        'revenue': price - cost,
        'productsPrice': productsPrice,
        'productsCount': count,
        'attributesPrice': price - productsPrice,
        'createdAt': createdAt,
      });

      for (final p in prods) {
        final productId = await txn.insert('order_products', {
          'orderId': orderId,
          'productName': p['productName'],
          'catalogName': p['catalogName'] ?? '',
          'count': p['count'],
          'singleCost': p['cost'] ?? 0,
          'singlePrice': p['singlePrice'],
          'originalPrice': p['originalPrice'],
          'isDiscount': p['isDiscount'] ? 1 : 0,
          'createdAt': createdAt,
        });

        final batch = txn.batch();
        for (Map<String, Object?> ing in (p['ingredients'] ?? [])) {
          batch.insert('order_ingredients', {
            'orderId': orderId,
            'orderProductId': productId,
            'ingredientName': ing['name'],
            'quantityName': ing['quantityName'],
            'additionalPrice': ing['additionalPrice'] ?? 0,
            'additionalCost': ing['additionalCost'] ?? 0,
            'amount': ing['amount'] ?? 0,
            'createdAt': createdAt,
          });
        }
        await batch.commit(noResult: true);
      }

      final batch = txn.batch();
      for (final a in attrs) {
        batch.insert('order_attributes', {
          'orderId': orderId,
          'name': a['name'],
          'optionName': a['optionName'],
          'mode': a['mode'] ?? 0,
          'modeValue': a['modeValue'],
          'createdAt': createdAt,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  List<Map<String, Object?>> rows;
  int step = 0;
  do {
    rows = await db.query(
      'order',
      orderBy: 'createdAt ASC',
      limit: limit,
      offset: limit * step++,
    );
    for (final row in rows) {
      try {
        await exec(row);
      } catch (e) {
        Log.err(e, 'db_migration_action_8');
      }
    }
  } while (rows.isNotEmpty);
}
