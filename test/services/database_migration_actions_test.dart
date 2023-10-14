import 'package:flutter_test/flutter_test.dart';
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
      final action = dbMigrationActions[testVersion]!;
      final db = await createDb(testVersion);

      await action(db);
    });

    setUpAll(() {
      Database.instance = Database();
      Database.instance.db = MockDatabase();
      initializeStorage();
    });
  });
}
