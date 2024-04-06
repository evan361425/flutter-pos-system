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
      final db = await databaseFactoryFfi.openDatabase(
        sqflite.inMemoryDatabasePath,
        options: sqflite.OpenDatabaseOptions(
          version: latestVer,
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
      await db.insert(
          'order', {'createdAt': 2000, "paid": 666, "totalPrice": 666, "productsPrice": 555, "totalCount": 666});
      // version 5 format, add column `cost`
      await db.insert('order',
          {'createdAt': 3000, "paid": 666, "cost": 111, "totalPrice": 666, "productsPrice": 555, "totalCount": 666});
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
        DateTime.fromMillisecondsSinceEpoch(0),
        DateTime.fromMillisecondsSinceEpoch(5000 * 1000),
      );

      const expected = [1001, 1002, 2000, 3000, 4000];
      for (final it in IterableZip([orders.map((e) => e.createdAt.millisecondsSinceEpoch), expected])) {
        expect(it[0], equals(it[1] * 1000));
      }
      final order = orders[4];
      expect(order.products.isNotEmpty, isTrue);
      expect(order.attributes.isNotEmpty, isTrue);
    });

    setUpAll(() {
      Database.instance = Database();
      Database.instance.db = MockDatabase();
      initializeStorage();
    });
  });
}
