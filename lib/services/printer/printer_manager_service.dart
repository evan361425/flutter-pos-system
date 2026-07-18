import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:ping_discover_network_plus/ping_discover_network_plus.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/printer_config.dart';
import 'package:usb_serial/usb_serial.dart';

/// Lightweight discovery result - not yet a saved [PrinterConfig].
@immutable
class DiscoveredPrinter {
  const DiscoveredPrinter({
    required this.name,
    required this.address,
    required this.type,
  });

  final String name;

  /// LAN IP (optionally `host:port`) or USB `vendorId:productId`.
  final String address;

  final PrinterConnectionType type;

  @override
  String toString() =>
      'DiscoveredPrinter(name: $name, address: $address, type: $type)';
}

/// Facade for LAN/USB thermal printer discovery, raw byte transport, and
/// connection testing.
///
/// Responsibilities (SRP):
/// - Discover devices on the local network / USB bus
/// - Send raw ESC/POS (or plain) bytes and dispose I/O immediately
/// - Validate a [PrinterConfig] via a short test print
///
/// Does **not** generate ticket layouts, persist configs, or dispatch by
/// category - those belong to later sprint steps.
class PrinterManagerService {
  PrinterManagerService({
    Duration lanTimeout = const Duration(seconds: 3),
    int lanPort = defaultLanPort,
    Future<List<UsbDevice>> Function()? listUsbDevices,
    Future<UsbPort?> Function(int vendorId, int productId)? createUsbPort,
  }) : _lanTimeout = lanTimeout,
       _lanPort = lanPort,
       _listUsbDevices = listUsbDevices ?? UsbSerial.listDevices,
       _createUsbPort =
           createUsbPort ?? ((vid, pid) => UsbSerial.create(vid, pid));

  static PrinterManagerService? _instance;

  /// Shared singleton used by UI / dispatch layers.
  static PrinterManagerService get instance =>
      _instance ??= PrinterManagerService();

  /// Standard raw TCP port for ESC/POS network printers.
  static const int defaultLanPort = 9100;

  /// Baud rate used when opening USB-serial adapters.
  /// Most ESC/POS USB-UART bridges ignore baud for bulk transfer once open;
  /// 9600 remains a safe default for CDC/FTDI dongles.
  static const int usbBaudRate = 9600;

  final Duration _lanTimeout;
  final int _lanPort;
  final Future<List<UsbDevice>> Function() _listUsbDevices;
  final Future<UsbPort?> Function(int vendorId, int productId) _createUsbPort;

  // ---------------------------------------------------------------------------
  // Discovery
  // ---------------------------------------------------------------------------

  /// Scans [subnet] (e.g. `192.168.1`) for hosts accepting TCP [port]
  /// (defaults to 9100 - raw ESC/POS).
  ///
  /// Uses a short per-host timeout so a /24 scan stays interactive.
  Future<List<DiscoveredPrinter>> scanNetworkPrinters(
    String subnet, {
    int? port,
    Duration hostTimeout = const Duration(milliseconds: 400),
  }) async {
    final scanPort = port ?? _lanPort;
    final normalized = _normalizeSubnet(subnet);
    final found = <DiscoveredPrinter>[];

    Log.out('Scanning $normalized:*:$scanPort', 'printer_scan_lan');

    try {
      final stream = NetworkAnalyzer.i.discover(
        normalized,
        scanPort,
        timeout: hostTimeout,
      );

      await for (final NetworkAddress addr in stream) {
        if (!addr.exists) continue;
        final ip = addr.ip;
        if (ip.isEmpty) continue;

        found.add(
          DiscoveredPrinter(
            name: 'LAN $ip',
            address: ip,
            type: PrinterConnectionType.lan,
          ),
        );
      }
    } catch (e, st) {
      Log.out(
        'LAN scan failed: $e',
        'printer_scan_lan',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    Log.out('Found ${found.length} LAN printer(s)', 'printer_scan_lan');
    return found;
  }

  /// Discovers USB serial devices (Android) via [UsbSerial].
  ///
  /// Address format: `vendorId:productId` so [sendBytes] can reconnect later.
  ///
  /// Note: targets USB-CDC / FTDI / CH340 class devices. Pure USB-printer-class
  /// (non-serial) endpoints are out of scope for this transport.
  /// Returns an empty list on unsupported platforms (iOS / desktop) instead of
  /// crashing the discovery UI.
  Future<List<DiscoveredPrinter>> scanUsbPrinters() async {
    if (kIsWeb || !(defaultTargetPlatform == TargetPlatform.android)) {
      Log.out('USB scan skipped (unsupported platform)', 'printer_scan_usb');
      return const [];
    }

    final found = <DiscoveredPrinter>[];
    final seen = <String>{};

    Log.out('Scanning USB printers', 'printer_scan_usb');

    try {
      final devices = await _listUsbDevices();
      for (final device in devices) {
        final vendorId = device.vid;
        final productId = device.pid;
        if (vendorId == null || productId == null) continue;

        final address = '$vendorId:$productId';
        if (!seen.add(address)) continue;

        final label = device.productName?.trim();
        found.add(
          DiscoveredPrinter(
            name: (label != null && label.isNotEmpty) ? label : 'USB $address',
            address: address,
            type: PrinterConnectionType.usb,
          ),
        );
      }
    } catch (e, st) {
      Log.out(
        'USB scan failed: $e',
        'printer_scan_usb',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    Log.out('Found ${found.length} USB printer(s)', 'printer_scan_usb');
    return found;
  }

  // ---------------------------------------------------------------------------
  // Bridge
  // ---------------------------------------------------------------------------

  /// Sends [bytes] to the printer described by [config], then releases the
  /// connection immediately (open -> write -> close).
  Future<void> sendBytes(PrinterConfig config, List<int> bytes) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'must not be empty');
    }

    switch (config.type) {
      case PrinterConnectionType.lan:
        await _sendLan(config.address, bytes);
      case PrinterConnectionType.usb:
        await _sendUsb(config.address, bytes);
    }
  }

  /// Opens a TCP socket to [address], writes [bytes], flushes, and destroys
  /// the socket in a `finally` block.
  ///
  /// Connection budget: [_lanTimeout] (3s by default). No keep-alive - thermal
  /// printers are treated as fire-and-forget endpoints.
  Future<void> _sendLan(String address, List<int> bytes) async {
    final parsed = _parseLanEndpoint(address);
    Socket? socket;

    Log.out('LAN send -> ${parsed.host}:${parsed.port}', 'printer_send_lan');

    try {
      socket = await Socket.connect(
        parsed.host,
        parsed.port,
        timeout: _lanTimeout,
      );

      socket.add(bytes);
      // Bound the write/flush phase with the same 3s budget as connect.
      await socket.flush().timeout(_lanTimeout);
    } on SocketException catch (e, st) {
      Log.out(
        'LAN socket error: $e',
        'printer_send_lan',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } on TimeoutException catch (e, st) {
      Log.out('LAN timeout: $e', 'printer_send_lan', error: e, stackTrace: st);
      rethrow;
    } finally {
      // destroy() aborts immediately; preferred over close() so half-open
      // sockets from failed tests do not accumulate during scans.
      socket?.destroy();
    }
  }

  Future<void> _sendUsb(String address, List<int> bytes) async {
    final ids = _parseUsbAddress(address);
    UsbPort? port;

    Log.out('USB send -> $address', 'printer_send_usb');

    try {
      port = await _createUsbPort(ids.vendorId, ids.productId);
      if (port == null) {
        throw StateError('USB port create failed for $address');
      }

      final opened = await port.open();
      if (!opened) {
        throw StateError('USB port open failed for $address');
      }

      await port.setDTR(true);
      await port.setRTS(true);
      await port.setPortParameters(
        usbBaudRate,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      await port.write(Uint8List.fromList(bytes));
    } finally {
      try {
        await port?.close();
      } catch (e, st) {
        Log.out(
          'USB close error: $e',
          'printer_send_usb',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Test
  // ---------------------------------------------------------------------------

  /// Prints a minimal validation slip and returns whether transport succeeded.
  ///
  /// Never throws - UI can gate "Save" on the boolean result.
  Future<bool> testConnection(PrinterConfig config) async {
    final payload = utf8.encode(
      'TEST PRINT - ${config.name}\n'
      'Type: ${config.type.name}\n'
      'Addr: ${config.address}\n'
      'Paper: ${config.paperSize.name}\n'
      '\n\n',
    );

    try {
      await sendBytes(config, payload);
      Log.out('Test OK for ${config.name}', 'printer_test');
      return true;
    } catch (e, st) {
      Log.out(
        'Test FAILED for ${config.name}: $e',
        'printer_test',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Accepts `192.168.1`, `192.168.1.`, or a full IP `192.168.1.10`.
  static String _normalizeSubnet(String subnet) {
    final trimmed = subnet.trim().replaceAll(RegExp(r'\.$'), '');
    final parts = trimmed.split('.');
    if (parts.length >= 3) {
      return parts.take(3).join('.');
    }
    throw ArgumentError.value(
      subnet,
      'subnet',
      'expected form xxx.xxx.xxx (e.g. 192.168.1)',
    );
  }

  /// Parses `host` or `host:port`. IPv6 is not supported in this sprint.
  ({String host, int port}) _parseLanEndpoint(String address) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(address, 'address', 'LAN address is empty');
    }

    final colon = trimmed.lastIndexOf(':');
    if (colon > 0 && colon < trimmed.length - 1) {
      final host = trimmed.substring(0, colon);
      final port = int.tryParse(trimmed.substring(colon + 1));
      if (port != null && port > 0 && port <= 65535) {
        return (host: host, port: port);
      }
    }
    return (host: trimmed, port: _lanPort);
  }

  /// Parses `vendorId:productId` produced by [scanUsbPrinters].
  static ({int vendorId, int productId}) _parseUsbAddress(String address) {
    final parts = address.split(':');
    if (parts.length < 2) {
      throw ArgumentError.value(
        address,
        'address',
        'USB address must be vendorId:productId',
      );
    }
    final vendorId = int.tryParse(parts[0]);
    final productId = int.tryParse(parts[1]);
    if (vendorId == null || productId == null) {
      throw ArgumentError.value(
        address,
        'address',
        'USB address must be vendorId:productId (integers)',
      );
    }
    return (vendorId: vendorId, productId: productId);
  }
}
