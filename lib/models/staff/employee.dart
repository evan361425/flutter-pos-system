import 'package:possystem/helpers/util.dart';

/// Offline RBAC role for a shared POS terminal.
enum EmployeeRole {
  server,
  manager;

  String get sqlValue => name;

  static EmployeeRole fromSql(Object? raw) {
    if (raw is String) {
      for (final value in EmployeeRole.values) {
        if (value.name == raw) return value;
      }
    }
    return EmployeeRole.server;
  }
}

/// Staff member who can unlock the terminal and own orders.
class Employee {
  Employee({
    String? id,
    required this.name,
    required this.passcode,
    this.role = EmployeeRole.server,
  }) : id = id ?? Util.uuidV4();

  /// Offline-first UUID — never auto-increment.
  final String id;

  final String name;

  /// 4–6 digit PIN stored locally (offline POS; not a cloud secret).
  final String passcode;

  final EmployeeRole role;

  bool get isManager => role == EmployeeRole.manager;

  bool get isServer => role == EmployeeRole.server;

  Employee copyWith({
    String? id,
    String? name,
    String? passcode,
    EmployeeRole? role,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      passcode: passcode ?? this.passcode,
      role: role ?? this.role,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'passcode': passcode,
      'role': role.sqlValue,
    };
  }

  factory Employee.fromMap(Map<String, Object?> map) {
    return Employee(
      id: map['id'] as String? ?? Util.uuidV4(),
      name: map['name'] as String? ?? '',
      passcode: map['passcode'] as String? ?? '',
      role: EmployeeRole.fromSql(map['role']),
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Employee && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
