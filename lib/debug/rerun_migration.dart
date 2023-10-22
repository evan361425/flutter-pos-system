import 'package:flutter/material.dart';
import 'package:possystem/services/database.dart';

class RerunMigration extends StatelessWidget {
  const RerunMigration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await Database.execMigrationAction(
          Database.instance.db,
          Database.latestVersion,
        );
      },
      label: const Text('重新執行 Migration'),
      icon: const Icon(Icons.clear_all_sharp),
    );
  }
}
