import 'dart:convert';

import 'package:possystem/helpers/logger.dart';
import 'package:sqflite/sqflite.dart' show Database;

/// Helper to migrate DB schema from legacy.
final dbMigrationActions = <int, Future<void> Function(Database)>{
  8: _makeOrderMoreEasyToAnalysis,
};

/// Formatting order structure and make it easy to analysis.
Future<void> _makeOrderMoreEasyToAnalysis(Database db, {limit = 100}) async {
  Future<void> exec(Map<String, Object?> row) async {
    final price = row['totalPrice'] as num? ?? 0;
    final productsPrice = row['productsPrice'] as num? ?? price;
    final createdAt = row['createdAt'] as int;
    final prods = _safeDecode(row['encodedProducts'] as String?);
    final attrs = _safeDecode(row['encodedAttributes'] as String?);

    final cost = prods.fold<num>(0, (v, e) => v + (e['cost'] as num? ?? 0));
    final count = prods.fold<int>(0, (v, e) => v + (e['count'] as int? ?? 1));

    await db.transaction((txn) async {
      final orderId = await txn.insert('order_records', {
        'paid': row['paid'] as num? ?? 0,
        'price': price,
        'cost': cost,
        'revenue': price - cost,
        'productsPrice': productsPrice,
        'productsCount': count,
        'attributesPrice': price - productsPrice,
        'createdAt': createdAt,
      });

      for (final p in prods) {
        final isDiscount = p['isDiscount'];
        final productId = await txn.insert('order_products', {
          'orderId': orderId,
          'productName': p['productName'] ?? '',
          'catalogName': p['catalogName'] ?? '',
          'count': p['count'] ?? 0,
          'singleCost': p['cost'] ?? 0,
          'singlePrice': p['singlePrice'] ?? 0,
          'originalPrice': p['originalPrice'] ?? 0,
          'isDiscount': isDiscount == 1 || isDiscount == true ? 1 : 0,
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
        await batch.commit(noResult: true, continueOnError: true);
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
      await batch.commit(noResult: true, continueOnError: true);
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
      await exec(row).catchError((e) {
        Log.err(e, 'db_migration_action_8');
      });
    }
  } while (rows.isNotEmpty);
}

List _safeDecode(String? val) {
  try {
    return jsonDecode(val ?? '[]');
  } catch (e) {
    return [];
  }
}
