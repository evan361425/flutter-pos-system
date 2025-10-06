import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/scaffold/item_modal.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/device.dart';
import 'package:possystem/services/network.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/device/widgets/device_view.dart';

class DeviceModal extends StatefulWidget {
  final Device? device;

  final bool isNew;

  const DeviceModal({super.key, this.device}) : isNew = device == null;

  @override
  State<DeviceModal> createState() => _DeviceModalState();
}

class _DeviceModalState extends State<DeviceModal> with ItemModal<DeviceModal> {
  Device? device;

  // discovery variables
  StreamSubscription<DiscoveredDevice>? discoveryStream;
  List<DiscoveredDevice> discovered = [];
  Future<void>? notFoundFuture;
  final notFoundFAB = ValueNotifier<bool>(false);

  // field variables
  bool autoConnect = false;
  DeviceType? deviceType;
  final nameController = TextEditingController(text: '');
  final nameFocusNode = FocusNode();
  final addressController = TextEditingController(text: '');
  final portController = TextEditingController(text: NetworkService.defaultPort.toString());

  @override
  String get title => widget.isNew ? 'Add Device' : 'Edit Device';

  @override
  List<Widget> buildFormFields() {
    if (device == null) {
      if (discovered.isEmpty) {
        return [
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator.adaptive()),
          const SizedBox(height: 16),
          HintText(
            'Searching for devices on the network...',
            textAlign: TextAlign.center,
          ),
        ];
      }

      return [
        const SizedBox(height: 8),
        HintText('Select a device to connect to:'),
        const SizedBox(height: 8),
        ...discovered.map(_buildDiscoveredDevice),
      ];
    }

    return [
      TextFormField(
        controller: nameController,
        focusNode: nameFocusNode,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Device Name',
          hintText: 'Kitchen Display',
        ),
        validator: Validator.textLimit(30),
        maxLength: 30,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: addressController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'IP Address',
          hintText: '192.168.1.100',
        ),
        validator: _validateAddress,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: portController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Port',
          hintText: '8765',
        ),
        validator: _validatePort,
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<DeviceType>(
        value: deviceType,
        decoration: const InputDecoration(
          labelText: 'Device Type',
        ),
        items: DeviceType.values.where((type) => type != DeviceType.unknown).map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(_getDeviceTypeName(type)),
          );
        }).toList(),
        onChanged: (value) => setState(() => deviceType = value),
        validator: (value) => value == null ? 'Please select a device type' : null,
      ),
      const SizedBox(height: 16),
      CheckboxListTile(
        title: const Text('Auto Connect'),
        subtitle: const Text('Automatically connect when ordering starts'),
        value: autoConnect,
        onChanged: (value) => setState(() => autoConnect = value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
      ),
      const SizedBox(height: 16),
      if (device != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Connection Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DeviceView(device: device!),
          ],
        ),
    ];
  }

  @override
  void initState() {
    super.initState();

    if (widget.device != null) {
      device = widget.device;
      _populateFields();
    } else {
      _startDiscovery();
    }
  }

  @override
  void dispose() {
    discoveryStream?.cancel();
    nameController.dispose();
    nameFocusNode.dispose();
    addressController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Future<void> updateItem() async {
    if (device == null) return;

    device!.name = nameController.text;
    device!.address = addressController.text;
    device!.port = int.parse(portController.text);
    device!.autoConnect = autoConnect;
    device!.deviceType = deviceType!;

    await device!.save();
  }

  @override
  Future<void> createItem() async {
    if (device == null) return;

    await Devices.instance.add(device!);
  }

  @override
  bool get canDelete => !widget.isNew;

  @override
  Future<void> deleteItem() async {
    await device!.remove();
  }

  void _populateFields() {
    if (device == null) return;

    nameController.text = device!.name;
    addressController.text = device!.address;
    portController.text = device!.port.toString();
    autoConnect = device!.autoConnect;
    deviceType = device!.deviceType;
  }

  void _startDiscovery() {
    Log.out('Starting device discovery', 'device_modal');

    // Start discovery timeout
    notFoundFuture = Future.delayed(const Duration(seconds: 10), () {
      if (mounted && discovered.isEmpty) {
        notFoundFAB.value = true;
      }
    });

    discoveryStream = NetworkService.instance.discoverDevices().listen(
      (discoveredDevice) {
        if (mounted) {
          setState(() {
            if (!discovered.contains(discoveredDevice)) {
              discovered.add(discoveredDevice);
            }
          });
        }
      },
      onError: (error) {
        Log.out('Discovery error: $error', 'device_modal');
        if (mounted) {
          showSnackBar('Discovery failed: $error', context: context);
        }
      },
      onDone: () {
        if (mounted && discovered.isEmpty) {
          notFoundFAB.value = true;
        }
      },
    );
  }

  Widget _buildDiscoveredDevice(DiscoveredDevice discoveredDevice) {
    return Card(
      child: ListTile(
        leading: Icon(_getDeviceTypeIcon(discoveredDevice.deviceType)),
        title: Text(discoveredDevice.name),
        subtitle: Text('${discoveredDevice.address}:${discoveredDevice.port}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _selectDevice(discoveredDevice),
      ),
    );
  }

  void _selectDevice(DiscoveredDevice discoveredDevice) {
    setState(() {
      device = Device(
        name: discoveredDevice.name,
        address: discoveredDevice.address,
        port: discoveredDevice.port,
        deviceType: DeviceType.fromString(discoveredDevice.deviceType),
        publicKey: discoveredDevice.publicKey,
      );
      _populateFields();
    });

    // Stop discovery
    discoveryStream?.cancel();
    discoveryStream = null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an IP address';
    }

    // Basic IP address validation
    final parts = value.split('.');
    if (parts.length != 4) {
      return 'Invalid IP address format';
    }

    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) {
        return 'Invalid IP address format';
      }
    }

    return null;
  }

  String? _validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a port number';
    }

    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) {
      return 'Port must be between 1 and 65535';
    }

    return null;
  }

  String _getDeviceTypeName(DeviceType type) {
    switch (type) {
      case DeviceType.cashier:
        return 'Cashier';
      case DeviceType.kitchen:
        return 'Kitchen Display';
      case DeviceType.display:
        return 'Display';
      case DeviceType.unknown:
        return 'Unknown';
    }
  }

  IconData _getDeviceTypeIcon(String deviceType) {
    switch (DeviceType.fromString(deviceType)) {
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

  @override
  Widget buildFloatingActionButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: notFoundFAB,
      builder: (context, show, child) {
        if (!show || device != null) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: _showManualEntryDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Manually'),
        );
      },
    );
  }

  void _showManualEntryDialog() {
    setState(() {
      device = Device();
      _populateFields();
    });
  }
}