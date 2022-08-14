import 'dart:convert';

import 'package:possystem/helpers/db_transferer.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/repository/customer_settings.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:sqflite/sqflite.dart' show Database, Sqflite;

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
      Log.ger('5', 'db_migration_action', orders.length.toString());

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
  6: (db) async {
    // convert CustomerSettings to OrderAttributes
    final legacy = CustomerSettings();
    await legacy.initialize();
    for (final setting in legacy.items) {
      final attr = OrderAttribute.fromObject(setting.toObject());
      await OrderAttributes.instance.addItem(attr);
    }
    Log.ger('6', 'db_migration_action',
        '${legacy.length} to ${OrderAttributes.instance.length}');

    // convert order to new format
    final totalCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM `order`')) ??
        0;
    const int step = 100;
    final count = (totalCount / step).ceil();
    Log.ger('6', 'db_migration_action', '$totalCount orders');

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
              'encodedAttributes': jsonEncode(
                  DBTransferer.parseCombination(item['combination'] as String?)
                      .entries
                      .map((e) =>
                          OrderSelectedAttributeObject.fromId(e.key, e.value))
                      .where((e) => e.isNotEmpty)
                      .map<Map<String, Object>>((e) => e.toMap())
                      .toList())
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          )
      ]);
      Log.out('done', 'db_migration_action_6');
    }
  },
};
