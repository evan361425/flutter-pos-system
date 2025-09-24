import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:possystem/helpers/logger.dart';

/// Network service for device-to-device communication
class NetworkService {
  static NetworkService instance = NetworkService();

  final Map<String, DeviceConnection> _connections = {};
  ServerSocket? _server;
  bool _isServerRunning = false;

  /// Default port for POS device communication
  static const int defaultPort = 8765;

  /// Start discovery server to listen for incoming connections
  Future<bool> startDiscoveryServer({int port = defaultPort}) async {
    if (_isServerRunning) return true;

    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _isServerRunning = true;

      Log.out('Discovery server started on port $port', 'network_service');

      _server!.listen((Socket socket) {
        Log.out('New connection from ${socket.remoteAddress.address}:${socket.remotePort}', 'network_service');
        _handleIncomingConnection(socket);
      });

      return true;
    } catch (e) {
      Log.out('Failed to start discovery server: $e', 'network_service');
      return false;
    }
  }

  /// Stop discovery server
  Future<void> stopDiscoveryServer() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      _isServerRunning = false;
      Log.out('Discovery server stopped', 'network_service');
    }
  }

  /// Connect to a remote device
  Future<DeviceConnection?> connectToDevice(String address, int port) async {
    final connectionId = '$address:$port';
    
    if (_connections.containsKey(connectionId)) {
      return _connections[connectionId];
    }

    try {
      final socket = await Socket.connect(address, port);
      final connection = DeviceConnection(socket, address, port);
      _connections[connectionId] = connection;

      Log.out('Connected to device at $address:$port', 'network_service');
      return connection;
    } catch (e) {
      Log.out('Failed to connect to device at $address:$port: $e', 'network_service');
      return null;
    }
  }

  /// Disconnect from a device
  Future<void> disconnectFromDevice(String address, int port) async {
    final connectionId = '$address:$port';
    final connection = _connections.remove(connectionId);
    await connection?.close();
  }

  /// Get all active connections
  List<DeviceConnection> get activeConnections => _connections.values.toList();

  /// Handle incoming connection from another device
  void _handleIncomingConnection(Socket socket) {
    final address = socket.remoteAddress.address;
    final port = socket.remotePort;
    final connectionId = '$address:$port';

    final connection = DeviceConnection(socket, address, port);
    _connections[connectionId] = connection;

    // Set up connection cleanup on disconnect
    connection.onDisconnected = () {
      _connections.remove(connectionId);
      Log.out('Connection from $address:$port disconnected', 'network_service');
    };
  }

  /// Discover devices on the local network
  Stream<DiscoveredDevice> discoverDevices({int timeout = 5}) async* {
    Log.out('Starting device discovery', 'network_service');

    // Get local network addresses
    final interfaces = await NetworkInterface.list(includeLoopback: false);
    
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          // Scan the subnet for devices
          yield* _scanSubnet(addr.address, timeout);
        }
      }
    }
  }

  /// Scan a subnet for POS devices
  Stream<DiscoveredDevice> _scanSubnet(String baseAddress, int timeout) async* {
    final parts = baseAddress.split('.');
    if (parts.length != 4) return;

    final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
    final List<Future<DiscoveredDevice?>> futures = [];

    // Scan common IP range (1-254)
    for (int i = 1; i <= 254; i++) {
      final targetAddress = '$subnet.$i';
      futures.add(_probeDevice(targetAddress, defaultPort, timeout));
    }

    // Process results as they complete
    await for (final result in Stream.fromFutures(futures)) {
      if (result != null) {
        yield result;
      }
    }
  }

  /// Probe a specific address for POS device
  Future<DiscoveredDevice?> _probeDevice(String address, int port, int timeout) async {
    try {
      final socket = await Socket.connect(address, port)
          .timeout(Duration(seconds: timeout));
      
      // Send discovery probe
      socket.add(utf8.encode(jsonEncode({
        'type': 'discovery_probe',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      })));

      // Wait for response
      final response = await socket.first.timeout(Duration(seconds: 2));
      final responseStr = utf8.decode(response);
      final responseData = jsonDecode(responseStr) as Map<String, dynamic>;

      await socket.close();

      if (responseData['type'] == 'discovery_response') {
        return DiscoveredDevice(
          address: address,
          port: port,
          name: responseData['device_name'] as String? ?? 'Unknown Device',
          deviceType: responseData['device_type'] as String? ?? 'pos_device',
          publicKey: responseData['public_key'] as String?,
        );
      }
    } catch (e) {
      // Device not responding or not a POS device
    }
    
    return null;
  }

  /// Generate a random pairing pin
  String generatePairingPin() {
    final random = Random.secure();
    return (1000 + random.nextInt(9000)).toString(); // 4-digit pin
  }

  /// Clean up all connections
  Future<void> dispose() async {
    await stopDiscoveryServer();
    
    final connectionFutures = _connections.values.map((conn) => conn.close());
    await Future.wait(connectionFutures);
    _connections.clear();
  }
}

/// Represents a connection to a remote device
class DeviceConnection {
  final Socket _socket;
  final String address;
  final int port;
  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();
  
  bool _isConnected = true;
  VoidCallback? onDisconnected;

  DeviceConnection(this._socket, this.address, this.port) {
    _socket.listen(
      _handleData,
      onDone: () {
        _isConnected = false;
        onDisconnected?.call();
        _messageController.close();
      },
      onError: (error) {
        Log.out('Connection error: $error', 'device_connection');
        _isConnected = false;
        onDisconnected?.call();
      },
    );
  }

  bool get isConnected => _isConnected;

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Send a message to the connected device
  Future<bool> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected) return false;

    try {
      final jsonStr = jsonEncode(message);
      final data = utf8.encode(jsonStr);
      _socket.add(data);
      return true;
    } catch (e) {
      Log.out('Failed to send message: $e', 'device_connection');
      return false;
    }
  }

  /// Send order data to the connected device
  Future<bool> sendOrderData(Map<String, dynamic> orderData) async {
    return sendMessage({
      'type': 'order_data',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': orderData,
    });
  }

  /// Close the connection
  Future<void> close() async {
    _isConnected = false;
    await _socket.close();
    _messageController.close();
  }

  void _handleData(Uint8List data) {
    try {
      final message = utf8.decode(data);
      final jsonData = jsonDecode(message) as Map<String, dynamic>;
      _messageController.add(jsonData);
    } catch (e) {
      Log.out('Failed to parse incoming data: $e', 'device_connection');
    }
  }
}

/// Represents a discovered device on the network
class DiscoveredDevice {
  final String address;
  final int port;
  final String name;
  final String deviceType;
  final String? publicKey;

  const DiscoveredDevice({
    required this.address,
    required this.port,
    required this.name,
    required this.deviceType,
    this.publicKey,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoveredDevice &&
        other.address == address &&
        other.port == port;
  }

  @override
  int get hashCode => Object.hash(address, port);
}

typedef VoidCallback = void Function();