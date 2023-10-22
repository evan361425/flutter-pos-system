import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:possystem/debug/rerun_migration.dart';
import 'package:possystem/services/database.dart';
import 'package:possystem/services/database_migration_actions.dart';

import '../services/database_test.mocks.dart';

void main() {
  group('DEBUG', () {
    testWidgets('Rerun the migration test', (tester) async {
      dbMigrationActions.remove(Database.latestVersion);
      Database.instance.db = MockDatabase();

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: RerunMigration()),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.clear_all_sharp));
      await tester.pumpAndSettle();
    });
  });
}
