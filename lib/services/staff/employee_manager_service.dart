import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/staff/employee.dart';
import 'package:possystem/services/database.dart';

/// Facade for offline staff CRUD and PIN-based session auth (RBAC).
///
/// Owns every SQLite read/write on `employees`. Callers must go through this
/// service — never query that table directly (Law 1.2 / 1.3).
///
/// Bootstrapping: [initialize] ensures at least one Manager exists so the
/// lock screen can never permanently lock the operator out on first boot.
class EmployeeManagerService extends ChangeNotifier {
  EmployeeManagerService._();

  static final instance = EmployeeManagerService._();

  static const String employeesTable = 'employees';

  /// Default first-boot Manager PIN — change immediately in Staff Settings.
  static const String defaultManagerPasscode = '0000';

  static const String defaultManagerName = 'Manager';

  Database get _db => .instance;

  Employee? _currentEmployee;

  bool _initialized = false;

  /// Currently unlocked staff member, or null when the terminal is locked.
  Employee? get currentEmployee => _currentEmployee;

  bool get isLoggedIn => _currentEmployee != null;

  bool get isManager => _currentEmployee?.isManager ?? false;

  /// Idempotent boot: ensure a default Manager exists when the table is empty.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await ensureDefaultManager();
  }

  /// Creates Manager / PIN [defaultManagerPasscode] iff zero employees exist.
  Future<void> ensureDefaultManager() async {
    try {
      final count = await _db.count(employeesTable) ?? 0;
      if (count > 0) return;

      final manager = Employee(
        name: defaultManagerName,
        passcode: defaultManagerPasscode,
        role: .manager,
      );
      await _db.push(employeesTable, manager.toMap());
      Log.ger('employee_bootstrap', {
        'id': manager.id,
        'role': manager.role.sqlValue,
      });
    } catch (e, stack) {
      Log.err(e, 'employee_bootstrap_failed', stack);
    }
  }

  /// Looks up [passcode]; on match sets [_currentEmployee] and notifies.
  Future<bool> login(String passcode) async {
    try {
      await ensureDefaultManager();

      final rows = await _db.query(
        employeesTable,
        where: 'passcode = ?',
        whereArgs: [passcode],
        limit: 1,
      );
      if (rows.isEmpty) {
        Log.ger('employee_login_failed', {'reason': 'unknown_pin'});
        return false;
      }

      _currentEmployee = Employee.fromMap(rows.first);
      Log.ger('employee_login', {
        'id': _currentEmployee!.id,
        'role': _currentEmployee!.role.sqlValue,
      });
      notifyListeners();
      return true;
    } catch (e, stack) {
      Log.err(e, 'employee_login_error', stack);
      return false;
    }
  }

  /// Clears the session so the lock screen is required again.
  void logout() {
    final id = _currentEmployee?.id;
    _currentEmployee = null;
    Log.ger('employee_logout', {'id': id});
    notifyListeners();
  }

  Future<List<Employee>> getEmployees() async {
    final rows = await _db.query(
      employeesTable,
      orderBy: 'name ASC',
    );
    return rows.map(Employee.fromMap).toList();
  }

  Future<Employee?> getEmployee(String id) async {
    final rows = await _db.query(
      employeesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Employee.fromMap(rows.first);
  }

  /// Insert or update. Enforces a unique PIN and at least one Manager.
  Future<void> saveEmployee(Employee employee) async {
    _assertValidPasscode(employee.passcode);

    final conflict = await _db.query(
      employeesTable,
      where: 'passcode = ? AND id != ?',
      whereArgs: [employee.passcode, employee.id],
      limit: 1,
    );
    if (conflict.isNotEmpty) {
      throw StateError('Passcode already in use');
    }

    final existing = await getEmployee(employee.id);
    if (existing == null) {
      await _db.push(employeesTable, employee.toMap());
      Log.ger('employee_create', {
        'id': employee.id,
        'role': employee.role.sqlValue,
      });
    } else {
      if (existing.isManager && !employee.isManager) {
        await _assertNotLastManager(employee.id);
      }
      await _db.update(employeesTable, employee.id, employee.toMap());
      Log.ger('employee_update', {
        'id': employee.id,
        'role': employee.role.sqlValue,
      });
      if (_currentEmployee?.id == employee.id) {
        _currentEmployee = employee;
      }
    }
    notifyListeners();
  }

  /// Deletes by id. Refuses to remove the last Manager.
  Future<void> deleteEmployee(String id) async {
    final target = await getEmployee(id);
    if (target == null) return;

    if (target.isManager) {
      await _assertNotLastManager(id);
    }

    await _db.delete(employeesTable, id);
    Log.ger('employee_delete', {'id': id});

    if (_currentEmployee?.id == id) {
      _currentEmployee = null;
    }
    notifyListeners();
  }

  Future<void> _assertNotLastManager(String excludingId) async {
    final managers = await _db.count(
      employeesTable,
      where: 'role = ? AND id != ?',
      whereArgs: [.manager.sqlValue, excludingId],
    );
    if ((managers ?? 0) < 1) {
      throw StateError('Cannot remove the last manager');
    }
  }

  void _assertValidPasscode(String passcode) {
    if (!RegExp(r'^\d{4,6}$').hasMatch(passcode)) {
      throw ArgumentError('Passcode must be 4 to 6 digits');
    }
  }

  /// Test seam: reset singleton session without touching SQLite.
  @visibleForTesting
  void resetSession() {
    _currentEmployee = null;
    _initialized = false;
  }
}
