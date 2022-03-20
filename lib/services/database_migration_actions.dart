import 'dart:convert';

import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:sqflite/sqflite.dart' show Database;

final dbMigrationActions = <int, Future<void> Function(Database)>{
  5: (db) async {
    int offset = 0;
    List<Map<String, Object?>> orders;
    do {
      orders = await db.query(
        Seller.orderTable,
        limit: 100,
        offset: offset,
        orderBy: 'createdAt asc',
      );
      offset += 100;
      info('Get ${orders.length} orders', 'db.migration_action.5');

      for (final orderRaw in orders) {
        final order = OrderObject.fromMap(orderRaw);
        final products = order.products.toList();
        int index = 0;
        final newProducts = order.parseToProductWithNull().map((product) {
          final obj = product == null ? products[index] : product.toObject();
          index++;
          return obj.toMap();
        }).toList();

        await db.update(
          Seller.orderTable,
          {'encodedProducts': jsonEncode(newProducts)},
          where: 'id = ?',
          whereArgs: [order.id],
        );
      }
    } while (orders.isNotEmpty);
  },
};
