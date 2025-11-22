import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/device.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/device/device_modal.dart';
import 'package:possystem/ui/device/widgets/device_view.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Connections'),
        actions: [
          IconButton(
            onPressed: _showHelp,
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Devices.instance,
        builder: (context, child) {
          final devices = Devices.instance.itemList;

          if (devices.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(kSpacing0),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return DeviceView(
                device: device,
                onTap: () => _editDevice(device),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, device),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                      ),
                    ),
                    if (!device.connected)
                      const PopupMenuItem(
                        value: 'connect',
                        child: ListTile(
                          leading: Icon(Icons.link),
                          title: Text('Connect'),
                        ),
                      )
                    else
                      const PopupMenuItem(
                        value: 'disconnect',
                        child: ListTile(
                          leading: Icon(Icons.link_off),
                          title: Text('Disconnect'),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDevice,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 80,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Devices Added',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          HintText(
            'Add devices to share order data\nbetween cashier and kitchen',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _addDevice,
            icon: const Icon(Icons.add),
            label: const Text('Add Device'),
          ),
        ],
      ),
    );
  }

  void _addDevice() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const DeviceModal(),
    );
  }

  void _editDevice(Device device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DeviceModal(device: device),
    );
  }

  void _handleMenuAction(String action, Device device) {
    switch (action) {
      case 'edit':
        _editDevice(device);
        break;
      case 'delete':
        _confirmDelete(device);
        break;
      case 'connect':
        device.connect();
        break;
      case 'disconnect':
        device.disconnect();
        break;
    }
  }

  void _confirmDelete(Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to delete "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              device.remove();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Device Connections'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Connect Multiple Devices',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Connect two or more devices to share order information. One device can take orders while another displays them.',
              ),
              SizedBox(height: 16),
              Text(
                'Device Types:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Cashier: Takes and processes orders'),
              Text('• Kitchen Display: Shows orders to prepare'),
              Text('• Display: Shows order status to customers'),
              SizedBox(height: 16),
              Text(
                'Pairing:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'For security, devices must be paired with a PIN code before sharing order data.',
              ),
              SizedBox(height: 16),
              Text(
                'Auto Connect:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Enable auto connect to automatically connect to devices when starting to take orders.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}