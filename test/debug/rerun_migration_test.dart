import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:possystem/debug/rerun_migration.dart';
import 'package:possystem/services/database.dart';

import '../services/database_test.mocks.dart';

void main() {
  group('DEBUG', () {
    testWidgets('Rerun the migration test', (tester) async {
      final db = MockDatabase();
      when(db.query(
        any,
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) => Future.value([]));
      Database.instance.db = db;

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: RerunMigration()),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.clear_all_sharp));
      await tester.pumpAndSettle();
    });
  });
}
