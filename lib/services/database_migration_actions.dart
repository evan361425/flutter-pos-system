import 'dart:convert';

import 'package:possystem/helpers/logger.dart';
import 'package:sqflite/sqflite.dart' show Database;

/// Helper to migrate DB schema from legacy.
final dbMigrationActions = <int, Future<void> Function(Database)>{
  8: _makeOrderMoreEasyToAnalysis,
};

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
