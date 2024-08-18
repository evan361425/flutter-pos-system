import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/debug/random_gen_order.dart';
import 'package:possystem/debug/rerun_migration.dart';
import 'package:possystem/services/cache.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug'), leading: const PopButton()),
      body: ListView(
        key: const Key('debug.list'),
        children: [
          ListTile(
            title: const Text('Generate orders'),
            trailing: const Icon(Icons.add_outlined),
            onTap: goGenerateRandomOrders(context),
          ),
          ListTile(
            title: const Text('Cache Reset'),
            trailing: const Icon(Icons.clear_all_outlined),
            onTap: Cache.instance.reset,
          ),
          const ListTile(
            title: Text('Migrate DB Again'),
            trailing: Icon(Icons.refresh_outlined),
            onTap: rerunMigration,
          )
        ],
      ),
    );
  }
}
