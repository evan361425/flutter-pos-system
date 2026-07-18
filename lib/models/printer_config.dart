import 'dart:convert';

/// Transport used by the managed printer module (LAN / USB).
///
/// Intentionally separate from the legacy Bluetooth [Printer] / [PrinterProvider]
/// stack so both systems can coexist without coupling.
enum PrinterConnectionType {
  lan,
  usb,
}

/// Thermal paper width supported by ESC/POS layout generation.
enum PaperSize {
  mm58,
  mm80,
}

extension PaperSizeX on PaperSize {
  /// Typical character columns for monospace ESC/POS Font A.
  int get charsPerLine => switch (this) {
        PaperSize.mm58 => 32,
        PaperSize.mm80 => 48,
      };
}

/// Dispatch role for smart ticket routing.
enum PrinterRole {
  cashier,
  kitchen,
}

/// Persisted configuration for a LAN or USB thermal printer.
///
/// Storage-agnostic: [toMap] / [fromMap] are suitable for Sembast, SQLite, or
/// SharedPreferences (JSON-encoded). Does not own discovery or I/O.
class PrinterConfig {
  const PrinterConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.paperSize,
    required this.role,
    this.assignedCategories = const [],
  });

  final String id;

  /// Human-readable label shown in settings and on test prints.
  final String name;

  final PrinterConnectionType type;

  /// LAN: IPv4 (`192.168.1.50`) or `host:port` (default port 9100).
  /// USB: `vendorId:productId` (hex or decimal as reported by the plugin).
  final String address;

  final PaperSize paperSize;

  final PrinterRole role;

  /// Product catalog names routed to this printer when [role] is kitchen.
  final List<String> assignedCategories;

  PrinterConfig copyWith({
    String? id,
    String? name,
    PrinterConnectionType? type,
    String? address,
    PaperSize? paperSize,
    PrinterRole? role,
    List<String>? assignedCategories,
  }) {
    return PrinterConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      paperSize: paperSize ?? this.paperSize,
      role: role ?? this.role,
      assignedCategories: assignedCategories ?? this.assignedCategories,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'address': address,
      'paperSize': paperSize.index,
      'role': role.index,
      'assignedCategories': List<String>.from(assignedCategories),
    };
  }

  /// JSON string form for SharedPreferences / SQLite TEXT columns.
  String toJson() => jsonEncode(toMap());

  factory PrinterConfig.fromMap(Map<String, Object?> map) {
    final categories = map['assignedCategories'];
    return PrinterConfig(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: PrinterConnectionType
          .values[_clampIndex(map['type'], PrinterConnectionType.values)],
      address: map['address'] as String? ?? '',
      paperSize:
          PaperSize.values[_clampIndex(map['paperSize'], PaperSize.values)],
      role: PrinterRole.values[_clampIndex(map['role'], PrinterRole.values)],
      assignedCategories: _parseStringList(categories),
    );
  }

  factory PrinterConfig.fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('PrinterConfig JSON must be an object');
    }
    return PrinterConfig.fromMap(Map<String, Object?>.from(decoded));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrinterConfig &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.address == address &&
        other.paperSize == paperSize &&
        other.role == role &&
        _listEquals(other.assignedCategories, assignedCategories);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        type,
        address,
        paperSize,
        role,
        Object.hashAll(assignedCategories),
      );

  @override
  String toString() =>
      'PrinterConfig(id: $id, name: $name, type: $type, address: $address, '
      'paperSize: $paperSize, role: $role, categories: $assignedCategories)';
}

int _clampIndex(Object? value, List<Enum> values) {
  final index = value is int ? value : int.tryParse('$value') ?? 0;
  if (index < 0 || index >= values.length) return 0;
  return index;
}

List<String> _parseStringList(Object? value) {
  if (value == null) return const [];
  if (value is List) {
    return value.map((e) => e.toString()).toList(growable: false);
  }
  if (value is String && value.isNotEmpty) {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList(growable: false);
    }
  }
  return const [];
}

bool _listEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
