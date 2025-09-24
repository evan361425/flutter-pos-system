import 'dart:async';

import 'package:flutter/material.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/device.dart';
import 'package:possystem/translator.dart';

class DeviceButtonView extends StatefulWidget {
  const DeviceButtonView({super.key});

  @override
  State<DeviceButtonView> createState() => _DeviceButtonViewState();
}

class _DeviceButtonViewState extends State<DeviceButtonView> {
  late final Set<String> devices;
  final List<Device> connected = [];
  final List<Device> connecting = [];

  @override
  Widget build(BuildContext context) {
    return Tutorial(
      id: 'order.device',
      title: 'Device Connection',
      message: 'Connect to other devices to share order data between cashier and kitchen.',
      child: ExpansionTile(
        leading: const Icon(Icons.devices),
        title: const Text('Devices'),
        subtitle: HintText(_getStatusText()),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          if (connected.isEmpty && connecting.isEmpty)
            const ListTile(
              title: Text('No devices connected'),
              subtitle: Text('Add devices in settings to connect them here'),
            )
          else
            ...connected.map(_buildConnectedDevice),
          ...connecting.map(_buildConnectingDevice),
        ],
      ),
    );
  }

  @override
  void initState() {
    _addConnected(Devices.instance.items.where((e) => e.connected));
    connecting.addAll(Devices.instance.items.where((e) => e.autoConnect && !e.connected));
    devices = Devices.instance.items.map((e) => e.id).toSet();

    // Watch device status changes
    for (final device in Devices.instance.items) {
      device.addListener(_deviceChanged);
    }

    _connectWantedDevices();

    super.initState();
  }

  @override
  void dispose() {
    for (final device in Devices.instance.items) {
      device.removeListener(_deviceChanged);
    }
    super.dispose();
  }

  void _connectWantedDevices() async {
    if (connecting.isNotEmpty) {
      Log.ger('connect_order_device', {'length': connecting.length});
      final names = connecting.map((e) => e.name).join(', ');
      await Future.wait([
        // [toList] create new list which avoid concurrent modification of the original list
        for (final device in connecting.toList())
          showSnackbarWhenFutureError(
            device.connect(),
            'order_device_connect',
            context: context,
          ),
      ]);

      // if failed, remove all connecting devices
      if (connecting.where((e) => !e.connected).isNotEmpty) {
        if (mounted) {
          Log.ger('order_device_failed', {'length': connecting.length});
          setState(connecting.clear);
        }
      } else {
        if (mounted) {
          showSnackBar('Devices connected: $names', context: context);
        }
      }
    }
  }

  void _deviceChanged([void _]) {
    if (mounted) {
      setState(() {
        final wanted = <Device>[];

        // Move newly connected devices from connecting to connected
        connecting.removeWhere((e) {
          if (e.connected) {
            wanted.add(e);
            return true;
          }

          return false;
        });

        // Remove disconnected devices from connected list
        connected.removeWhere((e) {
          if (!e.connected) {
            Log.out('device ${e.name}(${e.address}) disconnected', 'connect_order_device');
            showSnackBar('Device disconnected: ${e.name}', context: context);
            return true;
          }

          return false;
        });

        _addConnected(wanted);
      });
    }
  }

  void _addConnected(Iterable<Device> devices) {
    for (final device in devices) {
      Log.out('device ${device.name}(${device.address}) connected', 'connect_order_device');
      connected.add(device);
    }
  }

  String _getStatusText() {
    if (connected.isNotEmpty) {
      return '${connected.length} device(s) connected';
    } else if (connecting.isNotEmpty) {
      return 'Connecting to ${connecting.length} device(s)...';
    } else {
      return 'No devices available';
    }
  }

  Widget _buildConnectedDevice(Device device) {
    return ListTile(
      leading: Icon(_getDeviceIcon(device), color: Colors.green),
      title: Text(device.name),
      subtitle: Text('${device.address}:${device.port}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!device.isPaired)
            Chip(
              label: const Text('Not paired'),
              backgroundColor: Colors.orange[100],
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => device.disconnect(),
            tooltip: 'Disconnect',
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingDevice(Device device) {
    return ListTile(
      leading: Icon(_getDeviceIcon(device), color: Colors.orange),
      title: Text(device.name),
      subtitle: Text('Connecting to ${device.address}:${device.port}'),
      trailing: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  IconData _getDeviceIcon(Device device) {
    switch (device.deviceType) {
      case DeviceType.cashier:
        return Icons.point_of_sale;
      case DeviceType.kitchen:
        return Icons.kitchen;
      case DeviceType.display:
        return Icons.tv;
      default:
        return Icons.devices;
    }
  }
}