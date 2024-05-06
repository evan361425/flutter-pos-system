import 'package:possystem/services/database.dart';

void rerunMigration() async {
  await Database.execMigrationAction(
    Database.instance.db,
    Database.latestVersion,
  );
}
