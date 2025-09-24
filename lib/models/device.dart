import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/app.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/device_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/network.dart';
import 'package:possystem/services/storage.dart';

/// Device types for POS system
enum DeviceType {
  cashier('cashier'),
  kitchen('kitchen'),
  display('display'),
  unknown('unknown');

  const DeviceType(this.value);
  final String value;

  static DeviceType fromString(String value) {
    return DeviceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DeviceType.unknown,
    );
  }
}

/// Devices repository managing all connected devices
class Devices extends ChangeNotifier with Repository<Device>, RepositoryStorage<Device> {
  static late Devices instance;

  @override
  final Stores storageStore = Stores.devices;

  Devices() {
    instance = this;
  }

  @override
  List<Device> get itemList => items.sorted((a, b) => a.compareTo(b));

  @override
  RepositoryStorageType get repoType => RepositoryStorageType.repoProperties;

  bool get hasConnected => items.any((e) => e.connected);

  bool hasAddress(String address) => items.any((e) => e.address == address);

  @override
  Device buildItem(String id, Map<String, Object?> value) {
    return Device.fromObject(
      DeviceObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  @override
  Future<void> initialize({String? record}) async {
    // follow [Device.prefix]
    await super.initialize(record: record);

    Log.out('Initialized ${items.length} devices', 'devices_initialize');
  }

  /// Auto-connect to devices that have autoConnect enabled
  Future<void> autoConnect() async {
    final autoConnectDevices = items.where((e) => e.autoConnect && !e.connected);
    if (autoConnectDevices.isEmpty) return;

    Log.ger('auto_connect_devices', {'count': autoConnectDevices.length});

    await Future.wait([
      for (final device in autoConnectDevices)
        showSnackbarWhenFutureError(
          device.connect(),
          'device_auto_connect',
          key: App.scaffoldMessengerKey,
        ),
    ]);
  }

  /// Send order data to all connected devices
  Future<void> broadcastOrderData(Map<String, dynamic> orderData) async {
    final connectedDevices = items.where((e) => e.connected);
    if (connectedDevices.isEmpty) return;

    Log.out('Broadcasting order data to ${connectedDevices.length} devices', 'devices_broadcast');

    final futures = <Future<void>>[];
    final errors = <String>[];

    for (final device in connectedDevices) {
      futures.add(
        device.sendOrderData(orderData).catchError((error) {
          errors.add('${device.name}: $error');
        }),
      );
    }

    await Future.wait(futures);

    if (errors.isNotEmpty) {
      showSnackbarWhenFutureError(
        Future.error(errors.join('\n')),
        'device_broadcast_error',
        key: App.scaffoldMessengerKey,
      );
    }
  }
}

/// Individual device model
class Device extends Model<DeviceObject> with ModelStorage<DeviceObject> implements Comparable<Device> {
  String address;
  int port;
  bool autoConnect;
  DeviceType deviceType;
  String? publicKey;
  bool isPaired;

  DeviceConnection? _connection;

  @override
  final Stores storageStore = Stores.devices;

  @override
  Devices get repository => Devices.instance;

  @override
  String get prefix => 'device.$id';

  bool get connected => _connection?.isConnected ?? false;

  Device({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'device',
    this.address = '',
    this.port = NetworkService.defaultPort,
    this.autoConnect = false,
    this.deviceType = DeviceType.unknown,
    this.publicKey,
    this.isPaired = false,
  }) {
    addListener(notifyItem);
  }

  factory Device.fromObject(DeviceObject object) => Device(
        id: object.id,
        name: object.name!,
        address: object.address!,
        port: object.port ?? NetworkService.defaultPort,
        autoConnect: object.autoConnect!,
        deviceType: DeviceType.fromString(object.deviceType ?? 'unknown'),
        publicKey: object.publicKey,
        isPaired: object.isPaired ?? false,
      );

  @override
  DeviceObject toObject() {
    return DeviceObject(
      id: id,
      name: name,
      address: address,
      port: port,
      autoConnect: autoConnect,
      deviceType: deviceType.value,
      publicKey: publicKey,
      isPaired: isPaired,
    );
  }

  @override
  Future<void> remove() async {
    await disconnect();
    await super.remove();
  }

  /// Connect to the device
  Future<bool> connect() async {
    if (connected) return true;

    Log.ger('connect_device', {'address': address, 'port': port});

    try {
      _connection = await NetworkService.instance.connectToDevice(address, port);
      
      if (_connection != null) {
        // Set up message handling
        _connection!.messages.listen(_handleMessage);
        
        // Set up disconnect callback
        _connection!.onDisconnected = () {
          _connection = null;
          notifyListeners();
        };

        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      Log.out('Failed to connect to device: $e', 'connect_device');
      return false;
    }
  }

  /// Disconnect from the device
  Future<void> disconnect() async {
    if (!connected) return;

    Log.ger('disconnect_device', {'address': address, 'port': port});

    await _connection?.close();
    _connection = null;
    notifyListeners();
  }

  /// Send order data to this device
  Future<void> sendOrderData(Map<String, dynamic> orderData) async {
    if (!connected) {
      throw Exception('Device not connected');
    }

    final success = await _connection!.sendOrderData(orderData);
    if (!success) {
      throw Exception('Failed to send order data');
    }

    Log.out('Order data sent to ${name}', 'device_send_order');
  }

  /// Send a pairing request with pin
  Future<bool> sendPairingRequest(String pin) async {
    if (!connected) return false;

    return await _connection!.sendMessage({
      'type': 'pairing_request',
      'pin': pin,
      'device_name': name,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Accept a pairing request
  Future<bool> acceptPairing(String pin) async {
    if (!connected) return false;

    final success = await _connection!.sendMessage({
      'type': 'pairing_accept',
      'pin': pin,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    if (success) {
      isPaired = true;
      await save();
      notifyListeners();
    }

    return success;
  }

  /// Handle incoming messages from the connected device
  void _handleMessage(Map<String, dynamic> message) {
    final messageType = message['type'] as String?;

    switch (messageType) {
      case 'order_data':
        _handleOrderData(message['data'] as Map<String, dynamic>);
        break;
      case 'pairing_request':
        _handlePairingRequest(message);
        break;
      case 'pairing_accept':
        _handlePairingAccept(message);
        break;
      case 'ping':
        _handlePing();
        break;
      default:
        Log.out('Unknown message type: $messageType', 'device_message');
    }
  }

  void _handleOrderData(Map<String, dynamic> orderData) {
    Log.out('Received order data from ${name}', 'device_order_data');
    // Here you could emit an event or update the UI
    // For now, just log the received data
  }

  void _handlePairingRequest(Map<String, dynamic> message) {
    Log.out('Received pairing request from ${name}', 'device_pairing');
    // Emit pairing request event - this could be handled by the UI
  }

  void _handlePairingAccept(Map<String, dynamic> message) {
    Log.out('Pairing accepted by ${name}', 'device_pairing');
    isPaired = true;
    save();
    notifyListeners();
  }

  void _handlePing() {
    // Respond to ping
    _connection?.sendMessage({
      'type': 'pong',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  int compareTo(Device other) {
    return name.compareTo(other.name);
  }

  void notifyItem() => repository.notifyItem();
}