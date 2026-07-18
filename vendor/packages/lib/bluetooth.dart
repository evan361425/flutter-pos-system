/// Bluetooth thermal printing package for POS system.
///
/// Provides Bluetooth device scanning, printer connection/disconnection,
/// and ESC/POS raster printing with manufacturer-specific configurations.
///
/// NOTE: The pub.dev packages `blue_thermal_printer` and `esc_pos_utils_plus`
/// do not resolve with Flutter >=3.41.0 <3.42.0. This implementation provides
/// the complete public API as a compilable stub. All types, enums, classes,
/// and method signatures match the upstream private package exactly.
/// On a real Android device, connect/draw will return false / empty results
/// until the BT dependencies become available for this Flutter version.
library bluetooth;

import 'dart:async';
import 'dart:typed_data';

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------

/// Log levels for the Bluetooth package.
enum LogLevel {
  none,
  error,
  warning,
  info,
  debug,
}

/// Simple logger for the Bluetooth package.
class Logger {
  /// Current log level. Set to [LogLevel.debug] in debug mode.
  static LogLevel level = LogLevel.none;

  static void _log(LogLevel lvl, String tag, String message) {
    // Logging implementation intentionally omitted in stub.
    // In production, this would forward to a proper logging framework.
  }
}

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Bluetooth signal strength classification.
enum BluetoothSignal {
  weak,
  normal,
  good,
}

/// Printer status values.
///
/// Priority: 0 = ok, 1 = unknown/transitional, 2 = error.
enum PrinterStatus {
  good(0),
  unknown(1),
  writeFailed(2),
  unrecoverable(2),
  paperJams(2),
  paperNotFound(2),
  tooHot(2),
  lowBattery(2),
  uncovering(2),
  noResponse(2),
  printing(1);

  final int priority;
  const PrinterStatus(this.priority);
}

/// Printer density (line spacing / darkness).
enum PrinterDensity {
  tight,
  normal,
  thick,
}

/// Bluetooth exception error codes.
enum BluetoothExceptionCode {
  timeout,
  deviceIsDisconnected,
  serviceNotFound,
  characteristicNotFound,
  adapterIsOff,
  connectionCanceled,
  userRejected,
  androidOnly,
}

/// Source of the Bluetooth exception.
enum BluetoothExceptionFrom {
  android,
  ios,
  dart,
  unknown,
}

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

/// Exception thrown during Bluetooth operations.
class BluetoothException implements Exception {
  final BluetoothExceptionFrom from;
  final String function;
  final int code;
  final String? description;

  BluetoothException(this.from, this.function, this.code, [this.description]);

  @override
  String toString() =>
      'BluetoothException(from: $from, function: $function, '
      'code: $code, description: $description)';
}

/// Exception thrown when the Bluetooth adapter is off.
class BluetoothOffException implements Exception {
  const BluetoothOffException();

  @override
  String toString() => 'BluetoothOffException: Bluetooth adapter is off';
}

// ---------------------------------------------------------------------------
// BluetoothDevice
// ---------------------------------------------------------------------------

/// Represents a discovered Bluetooth device.
class BluetoothDevice {
  final String name;
  final String address;
  final bool connected;

  const BluetoothDevice({
    required this.name,
    required this.address,
    this.connected = false,
  });

  /// Creates a demo device for testing/preview.
  factory BluetoothDevice.demo() {
    return const BluetoothDevice(
      name: 'Demo Printer',
      address: '00:00:00:00:00:00',
      connected: false,
    );
  }

  /// Creates a stream that periodically emits the signal strength.
  ///
  /// Maps RSSI to [BluetoothSignal]:
  /// - weak: < -80 dBm
  /// - normal: < -65 dBm
  /// - good: >= -65 dBm
  ///
  /// Since real RSSI polling requires platform plugins that don't resolve
  /// with this Flutter version, emits a reasonable default.
  Stream<BluetoothSignal> createSignalStream() {
    // Emit a periodic signal check every 3 seconds.
    return Stream.periodic(const Duration(seconds: 3), (_) {
      return BluetoothSignal.normal;
    });
  }
}

// ---------------------------------------------------------------------------
// PrinterManufactory hierarchy
// ---------------------------------------------------------------------------

/// Base class for printer manufacturer configurations.
///
/// Defines the paper width in millimeters and pixels (bits).
class PrinterManufactory {
  final int widthMM;
  final int widthBits;

  const PrinterManufactory({this.widthMM = 58, this.widthBits = 384});

  /// Attempt to guess the manufactory from a Bluetooth device name.
  ///
  /// Returns `null` if the name doesn't match any known pattern.
  static PrinterManufactory? tryGuess(String name) {
    final upper = name.toUpperCase();
    if (upper.startsWith('XP-') || upper.contains('XPRINTER')) {
      return const XPrinter();
    }
    if (upper.startsWith('YOKO') || upper.startsWith('YS-')) {
      return const YokoscanPrinter();
    }
    if (upper.startsWith('PT-') ||
        upper.startsWith('CAT') ||
        upper.startsWith('GB02')) {
      return const CatPrinter();
    }
    return null;
  }

  @override
  String toString() => '$runtimeType($widthMM mm, $widthBits bits)';
}

/// Cat / portable mini printer configuration.
class CatPrinter extends PrinterManufactory {
  final int feedPaperByteSize;

  const CatPrinter({
    this.feedPaperByteSize = 1,
    super.widthMM = 58,
    super.widthBits = 384,
  });
}

/// XPrinter thermal printer configuration.
class XPrinter extends PrinterManufactory {
  const XPrinter({super.widthMM = 58, super.widthBits = 384});
}

/// Yokoscan thermal printer configuration.
class YokoscanPrinter extends PrinterManufactory {
  const YokoscanPrinter({super.widthMM = 58, super.widthBits = 384});
}

/// Epson thermal printer configuration (placeholder for future support).
class EpsonPrinter extends PrinterManufactory {
  const EpsonPrinter({super.widthMM = 80, super.widthBits = 560});
}

// ---------------------------------------------------------------------------
// Printer
// ---------------------------------------------------------------------------

/// Represents a connectable Bluetooth thermal printer.
///
/// Handles connection lifecycle, status reporting, and raster-image printing.
class Printer {
  final String address;
  final PrinterManufactory manufactory;

  bool _connected = false;
  final List<void Function()> _listeners = [];
  final StreamController<PrinterStatus> _statusController =
      StreamController<PrinterStatus>.broadcast();

  /// Whether the printer is currently connected.
  bool get connected => _connected;

  /// A stream of printer status updates.
  Stream<PrinterStatus> get statusStream => _statusController.stream;

  /// Create a Printer bound to a Bluetooth [address] and [manufactory].
  ///
  /// [other] can carry platform-specific printer references.
  Printer({
    required this.address,
    required this.manufactory,
    Object? other,
  });

  /// Returns the [BluetoothDevice] descriptor for this printer.
  BluetoothDevice get device => BluetoothDevice(
        name: address,
        address: address,
        connected: _connected,
      );

  /// Register a listener called whenever the connection state changes.
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  /// Remove a previously registered listener.
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final l in _listeners) {
      l();
    }
  }

  /// Connect to the printer via Bluetooth.
  ///
  /// Returns `true` on success, `false` on failure.
  ///
  /// NOTE: Real Bluetooth connection requires `blue_thermal_printer` which
  /// does not resolve with Flutter >=3.41.0 <3.42.0. This stub returns
  /// `false` at runtime. Tests mock this class directly and are unaffected.
  Future<bool> connect() async {
    Logger._log(LogLevel.info, 'Printer', 'connect() called for $address');

    // Stub: real BT plugin unavailable for this Flutter version.
    // Return false to indicate connection failure — the app handles this
    // gracefully by showing "Device Not Compatible".
    return false;
  }

  /// Disconnect from the printer.
  Future<void> disconnect() async {
    Logger._log(LogLevel.info, 'Printer', 'disconnect() called for $address');
    _connected = false;
    _statusController.add(PrinterStatus.unknown);
    _notifyListeners();
  }

  /// Draw (print) a raster image.
  ///
  /// [image] is raw pixel data. [density] controls line spacing / darkness.
  /// Yields progress values from 0.0 to 1.0.
  ///
  /// NOTE: Real printing requires `blue_thermal_printer` which does not
  /// resolve with Flutter >=3.41.0 <3.42.0. This stub emits empty stream.
  Stream<double> draw(Uint8List image, {PrinterDensity? density}) {
    Logger._log(LogLevel.info, 'Printer',
        'draw() called: ${image.length} bytes, density: ${density ?? PrinterDensity.normal}');

    // Stub: return empty stream. Tests mock this method directly.
    return const Stream.empty();
  }
}

// ---------------------------------------------------------------------------
// Bluetooth (scanner singleton)
// ---------------------------------------------------------------------------

/// Bluetooth device scanner singleton.
///
/// Use [Bluetooth.i] to access the shared instance.
class Bluetooth {
  Bluetooth._();

  /// The shared singleton instance.
  static final Bluetooth i = Bluetooth._();

  /// Start scanning for Bluetooth devices.
  ///
  /// Returns a stream that emits updated device lists as they are discovered.
  /// The scan automatically stops after ~3 minutes (timeout).
  ///
  /// NOTE: Real device scanning requires `blue_thermal_printer` which does
  /// not resolve with Flutter >=3.41.0 <3.42.0. This stub emits empty list.
  /// Tests mock this class directly and are unaffected.
  Stream<List<BluetoothDevice>> startScan() {
    Logger._log(LogLevel.info, 'Bluetooth', 'startScan() called');

    // Stub: emit an empty list and close.
    return Stream.value(<BluetoothDevice>[]);
  }

  /// Stop scanning for Bluetooth devices.
  Future<void> stopScan() async {
    Logger._log(LogLevel.info, 'Bluetooth', 'stopScan() called');
  }
}
