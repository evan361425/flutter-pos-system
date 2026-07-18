import 'package:flutter/material.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/integration/cloud_config.dart';
import 'package:possystem/services/integration/cloud_sync_service.dart';
import 'package:possystem/services/staff/employee_manager_service.dart';
import 'package:possystem/services/sync/sync_service.dart';

/// Manager-only settings for e-commerce / cloud sync credentials and outbox errors.
class CloudSyncSettingsScreen extends StatefulWidget {
  const CloudSyncSettingsScreen({super.key});

  @override
  State<CloudSyncSettingsScreen> createState() =>
      _CloudSyncSettingsScreenState();
}

class _CloudSyncSettingsScreenState extends State<CloudSyncSettingsScreen> {
  late final TextEditingController _storeUrlController;
  late final TextEditingController _apiKeyController;
  late bool _isActive;
  late Future<List<SyncQueueFailure>> _failuresFuture;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final config = CloudConfig.load();
    _storeUrlController = TextEditingController(text: config.storeUrl);
    _apiKeyController = TextEditingController(text: config.apiKey);
    _isActive = config.isActive;
    _failuresFuture = SyncService.instance.getFailedItems();
  }

  @override
  void dispose() {
    _storeUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _refreshFailures() async {
    setState(() {
      _failuresFuture = SyncService.instance.getFailedItems();
    });
    await _failuresFuture;
  }

  Future<void> _save() async {
    if (!EmployeeManagerService.instance.isManager) {
      showSnackBar('Managers only', context: context);
      return;
    }

    setState(() => _saving = true);
    try {
      final config = CloudConfig(
        storeUrl: _storeUrlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        isActive: _isActive,
      );
      await config.save();
      CloudSyncService.instance.applyConfig(config);
      if (!mounted) return;
      showSnackBar('Cloud sync settings saved', context: context);
      await _refreshFailures();
    } catch (e, stack) {
      Log.err(e, 'cloud_settings_save_failed', stack);
      if (!mounted) return;
      showSnackBar('Failed to save settings', context: context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!EmployeeManagerService.instance.isManager) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cloud Sync'),
          leading: const PopButton(),
        ),
        body: const Center(
          child: Text('Only managers can configure cloud sync.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync'),
        leading: const PopButton(),
        actions: [
          TextButton(
            key: const Key('cloud_sync.save'),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile.adaptive(
            key: const Key('cloud_sync.active'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable cloud sync'),
            subtitle: const Text(
              'Push inventory updates and poll web orders',
            ),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('cloud_sync.store_url'),
            controller: _storeUrlController,
            decoration: const InputDecoration(
              labelText: 'Store URL',
              hintText: 'https://api.example.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('cloud_sync.api_key'),
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Outbox failures',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                key: const Key('cloud_sync.refresh_failures'),
                tooltip: 'Refresh',
                onPressed: _refreshFailures,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<SyncQueueFailure>>(
            future: _failuresFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              }

              final failures = snapshot.data ?? const <SyncQueueFailure>[];
              if (failures.isEmpty) {
                return const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('No failed sync jobs'),
                  subtitle: Text('The outbox is clear'),
                );
              }

              return Column(
                children: [
                  for (final failure in failures)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.error_outline),
                      title: Text(failure.endpoint),
                      subtitle: Text(
                        '${failure.errorMessage}\n'
                        'Retries: ${failure.retryCount} · '
                        '${failure.createdAt.toLocal()}',
                      ),
                      isThreeLine: true,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
