import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/models/objects/order_attribute_object.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_attribute.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/repository/order_attributes.dart';
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

    test('6 - customer_setting to order_attribute', () async {
      const testVersion = 6;
      final action = dbMigrationActions[testVersion] as Future<void> Function(
        sqflite.Database db, {
        int step,
        bool withLegacy,
        bool withOrder,
      });
      final db = await createDb(testVersion);

      OrderAttributes();

      testCS2Attr() async {
        // preparation
        await db.execute('INSERT INTO `customer_settings` '
            '(id, name, `index`, mode, isDelete) VALUES '
            '(1, "c-1", 1, 1, 0),'
            '(2, "c-2", 2, 0, 0),'
            '(3, "c-3", 3, 2, 0),'
            '(4, "c-4", 1, 100, 0),'
            '(5, "c-5", 1, 2, 1);');
        await db.execute('INSERT INTO `customer_setting_options` '
            '(id, customerSettingId, name, `index`, isDefault, modeValue, isDelete) VALUES '
            '(1, 1, "co-1", 1, 1, 1, 0),'
            '(2, 1, "co-2", 2, 0, null, 0),'
            '(3, 2, "co-3", 0, 0, null, 0),'
            '(4, 2, "co-4", 1, 0, 1, 0),'
            '(5, 2, "co-5", 2, 0, null, 1);');

        await action(db, withOrder: false);

        verifyAttr(OrderAttribute a, int id, OrderAttributeMode mode) {
          expect(a.id, id.toString());
          expect(a.name, 'c-$id');
          expect(a.index, id);
          expect(a.mode, mode);
        }

        verifyOpt(OrderAttributeOption opt, int id, bool isDefault, num? val) {
          expect(opt.id, id.toString());
          expect(opt.name, 'co-$id');
          expect(opt.isDefault, isDefault);
          expect(opt.modeValue, val);
        }

        final items = OrderAttributes.instance.itemList;
        expect(items.length, 3);
        verifyAttr(items[0], 1, OrderAttributeMode.changePrice);
        verifyAttr(items[1], 2, OrderAttributeMode.statOnly);
        verifyAttr(items[2], 3, OrderAttributeMode.changeDiscount);

        final opt1 = items[0].itemList;
        expect(opt1.length, 2);
        verifyOpt(opt1[0], 1, true, 1);
        verifyOpt(opt1[1], 2, false, null);

        final opt2 = items[1].itemList;
        expect(opt2.length, 2);
        verifyOpt(opt2[0], 3, false, null);
        verifyOpt(opt2[1], 4, false, 1);

        expect(items[2].length, 0);
      }

      testOrder() async {
        // preparation
        const defaultOrder = '1,2,3,4,"p1,p2","i1,i2","some-txt",5';
        await db.execute('INSERT INTO `order` '
            '(paid, totalPrice, totalCount, createdAt, usedProducts, usedIngredients, encodedProducts, productsPrice, customerSettingCombinationId) VALUES '
            '($defaultOrder, 1),'
            '($defaultOrder, 2),'
            '($defaultOrder, 3),'
            '($defaultOrder, 4),'
            '($defaultOrder, 5),'
            '($defaultOrder, 6),'
            '($defaultOrder, 7),'
            '($defaultOrder, 8);');
        // supported pairs are: 1:1~2, 2:3~4
        await db.execute('INSERT INTO `customer_setting_combinations` '
            '(id, combination) VALUES '
            '(1, "1:1"), '
            '(2, "1:1,2:3"), '
            '(3, "1:1,2:4"), '
            '(4, "1:2"), '
            '(5, "1:2,2:3"), '
            '(6, "1:2,2:4"), '
            '(7, "2:3"), '
            '(8, "2:4");');
        await db.execute('INSERT INTO `order_stash` '
            '(createdAt, encodedProducts, customerSettingCombinationId) VALUES '
            '(1, "some-txt", 1);');

        await action(db, step: 3, withLegacy: false);

        final orders =
            (await db.query('order', columns: ['id', 'encodedAttributes']))
                .map((e) => OrderObject.fromMap(e))
                .toList();
        const expected = <String>[
          'c-1:co-1',
          'c-1:co-1,c-2:co-3',
          'c-1:co-1,c-2:co-4',
          'c-1:co-2',
          'c-1:co-2,c-2:co-3',
          'c-1:co-2,c-2:co-4',
          'c-2:co-3',
          'c-2:co-4',
        ];
        var idx = 0;
        for (var val in expected) {
          expect(
            val,
            orders[idx++]
                .attributes
                .map((e) => '${e.name}:${e.optionName}')
                .join(','),
          );
        }
      }

      await testCS2Attr();
      await testOrder();
    });

    setUpAll(() {
      Database.instance = Database();
      Database.instance.db = MockDatabase();
      initializeStorage();
    });
  });
}
