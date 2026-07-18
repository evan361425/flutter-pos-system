import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/database_migration_actions.dart';
import 'package:possystem/services/database_migrations.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactoryFfi;

import '../mocks/mock_storage.dart';
import 'database_test.mocks.dart';

void main() {
  group('Database Migration Actions', () {
    Future<sqflite.Database> createDb(int latestVer) async {
      final path =
          '${Directory.systemTemp.path}/posflu_mig_${latestVer}_${DateTime.now().microsecondsSinceEpoch}.sqlite';
      final db = await databaseFactoryFfi.openDatabase(
        path,
        options: sqflite.OpenDatabaseOptions(
          version: latestVer,
          singleInstance: false,
          onCreate: (db, version) async {
            for (var ver = 1; ver <= version; ver++) {
              final sqlSet = dbMigrationUp[ver];
              if (sqlSet == null) continue;

              for (final sql in sqlSet) {
                await db.execute(sql);
              }
            }
          },
        ),
      );

      Database.instance.db = db;

      return db;
    }

    test('8 - make order more easy to analysis', () async {
      const testVersion = 8;
      final action = dbMigrationActions[testVersion] as Function;
      final db = await createDb(testVersion);

      // legacy table
      await db.execute('''CREATE TABLE `order` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  paid REAL DEFAULT NULL,
  totalPrice REAL DEFAULT NULL,
  totalCount INTEGER  DEFAULT NULL,
  productsPrice REAL DEFAULT 0,
  `cost` INTEGER DEFAULT 0,
  createdAt INTEGER DEFAULT NULL,
  usedProducts TEXT DEFAULT NULL,
  usedIngredients TEXT DEFAULT NULL,
  encodedProducts BLOB DEFAULT "",
  `encodedAttributes` BLOB DEFAULT "",
  `catalogName` BLOB DEFAULT ""
);''');

      // ===== prepare rows =====
      // wrong data should able to catch and go on.
      await db.insert('order', {
        'createdAt': 1000,
        'encodedProducts': '[{"cost":""}]',
      });
      await db.insert('order', {'createdAt': 1001, 'encodedProducts': '{[]}'});
      // version 1 format
      await db.insert('order', {
        'paid': 666,
        'totalPrice': 666,
        'totalCount': 666,
        'createdAt': 1002,
        'usedProducts': 'This column will not be used',
        'usedIngredients': 'This column will not be used',
        'encodedProducts': '''[{"_":"test fully empty"}, {
          "_": "really legacy format",
          "productName": "p-1",
          "count": 555,
          "singlePrice": 555,
          "originalPrice": 555,
          "isDiscount": true
        }]''',
      });
      // version 4 format, add column `customerSettingCombinationId` and `productsPrice`
      await db.insert('order', {
        'createdAt': 2000,
        "paid": 666,
        "totalPrice": 666,
        "productsPrice": 555,
        "totalCount": 666,
      });
      // version 5 format, add column `cost`
      await db.insert('order', {
        'createdAt': 3000,
        "paid": 666,
        "cost": 111,
        "totalPrice": 666,
        "productsPrice": 555,
        "totalCount": 666,
      });
      // version 6 format, add column `encodedAttributes`
      await db.insert('order', {
        'createdAt': 4000,
        "paid": 666,
        "cost": 111,
        "totalPrice": 666,
        "productsPrice": 555,
        "totalCount": 666,
        "encodedProducts": '''[{
          "productName": "p-1",
          "catalogName": "c-1",
          "count": 555,
          "cost": 555,
          "singlePrice": 555,
          "originalPrice": 555,
          "isDiscount": "1",
          "ingredients": [
            {"_": "test fully empty"},
            {"_": "no quantity","name": "i-1","amount":444},
            {
              "name": "i-1",
              "quantityName": "q-1",
              "additionalPrice": 444,
              "additionalCost": 444,
              "amount": 444
            }
          ]
        }]''',
        "encodedAttributes": '''[{}, {
          "_": "wrong mode",
          "name": "a-1",
          "optionName": "ao-1",
          "mode": 4
        }, {
          "_": "null mode value",
          "name": "a-2",
          "optionName": "ao-2",
          "mode": 1
        }, {
          "name": "a-3",
          "optionName": "ao-3",
          "mode": 1,
          "modeValue": 2.22
        }]''',
      });

      await action(db, limit: 2);

      // Assertion
      final orders = await Seller.instance.getDetailedOrders(
        .fromMillisecondsSinceEpoch(0),
        .fromMillisecondsSinceEpoch(5000 * 1000),
      );

      const expected = [1001, 1002, 2000, 3000, 4000];
      for (final it in IterableZip([
        orders.map((e) => e.createdAt.millisecondsSinceEpoch),
        expected,
      ])) {
        expect(it[0], equals(it[1] * 1000));
      }
      final order = orders[4];
      expect(order.products.isNotEmpty, isTrue);
      expect(order.attributes.isNotEmpty, isTrue);
    });

    test('12 - backfill payments from legacy paid', () async {
      // Simulate a real upgrade path: schema at v11, then migrate to v12.
      final db = await createDb(11);

      final id1 = await db.insert('order_records', {
        'paid': 50,
        'price': 45,
        'cost': 10,
        'revenue': 35,
        'productsPrice': 45,
        'productsCount': 1,
        'attributesPrice': 0,
        'createdAt': 1000,
      });
      final id2 = await db.insert('order_records', {
        'paid': 100,
        'price': 100,
        'cost': 20,
        'revenue': 80,
        'productsPrice': 100,
        'productsCount': 2,
        'attributesPrice': 0,
        'createdAt': 2000,
      });

      await Database.execMigration(db, 12);
      // Pre-fill one row as already migrated to assert idempotency.
      await db.update(
        'order_records',
        {
          'payments': jsonEncode([
            {'amount': 100, 'method': 'card'},
          ]),
        },
        where: 'id = ?',
        whereArgs: [id2],
      );
      await Database.execMigrationAction(db, 12);

      final row1 = (await db.query(
        'order_records',
        where: 'id = ?',
        whereArgs: [id1],
      )).first;
      expect(row1['paid'], 50);
      expect(row1['totalTax'], 0);
      final payments1 = jsonDecode(row1['payments'] as String) as List;
      expect(payments1, [
        {'amount': 50, 'method': 'cash'},
      ]);

      final row2 = (await db.query(
        'order_records',
        where: 'id = ?',
        whereArgs: [id2],
      )).first;
      expect(row2['paid'], 100);
      final payments2 = jsonDecode(row2['payments'] as String) as List;
      expect(payments2, [
        {'amount': 100, 'method': 'card'},
      ]);

      // Idempotent: second run must not rewrite already-filled payments.
      await Database.execMigrationAction(db, 12);
      final row2Again = (await db.query(
        'order_records',
        where: 'id = ?',
        whereArgs: [id2],
      )).first;
      expect(jsonDecode(row2Again['payments'] as String), [
        {'amount': 100, 'method': 'card'},
      ]);

      final columns = await db.rawQuery('PRAGMA table_info(order_records)');
      expect(columns.any((c) => c['name'] == 'payments'), isTrue);
      expect(columns.any((c) => c['name'] == 'totalTax'), isTrue);

      final productColumns = await db.rawQuery(
        'PRAGMA table_info(order_products)',
      );
      expect(productColumns.any((c) => c['name'] == 'taxRate'), isTrue);

      await db.close();
    });

    setUpAll(() {
      Database.instance = Database();
      Database.instance.db = MockDatabase();
      initializeStorage();
    });
  });
}
