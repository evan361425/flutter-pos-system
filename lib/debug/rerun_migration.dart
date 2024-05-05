import 'package:flutter/material.dart';
import 'package:possystem/services/database.dart';

class RerunMigration extends StatelessWidget {
  const RerunMigration({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await Database.execMigrationAction(
          Database.instance.db,
          Database.latestVersion,
        );
      },
      label: const Text('Migrate DB Again'),
      icon: const Icon(Icons.clear_all_sharp),
    );
  }
}
