import 'package:flutter/foundation.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/shift/shift.dart';
import 'package:possystem/services/database.dart';

/// Facade for cash-register shift lifecycle (open → sales → close / Z-report).
///
/// Owns every SQLite read/write on `shifts`. Callers must go through this
/// service — never query that table directly (Law 1.2 / 1.3).
///
/// On [initialize], hydrates [_currentShift] from any row with `status = open`
/// so a crash mid-shift does not orphan the drawer.
class ShiftManagerService extends ChangeNotifier {
  ShiftManagerService._();

  static final ShiftManagerService instance = ShiftManagerService._();

  static const String shiftsTable = 'shifts';

  Database get _db => Database.instance;

  Shift? _currentShift;

  bool _initialized = false;

  /// Active open shift, or null when the register is closed.
  Shift? get currentShift => _currentShift;

  bool get hasOpenShift => _currentShift != null && _currentShift!.isOpen;

  /// Boot: load any open shift from SQLite (idempotent).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _hydrateOpenShift();
  }

  Future<void> _hydrateOpenShift() async {
    try {
      final rows = await _db.query(
        shiftsTable,
        where: 'status = ?',
        whereArgs: [ShiftStatus.open.sqlValue],
        orderBy: 'start_time DESC',
        limit: 1,
      );
      _currentShift = rows.isEmpty ? null : Shift.fromMap(rows.first);
      if (_currentShift != null) {
        Log.ger('shift_hydrated', {'id': _currentShift!.id});
      }
      notifyListeners();
    } catch (e, stack) {
      Log.err(e, 'shift_hydrate_failed', stack);
      _currentShift = null;
    }
  }

  /// Opens a new shift with [startingCash] float for [employeeId].
  ///
  /// Throws [StateError] if a shift is already open.
  Future<Shift> openShift({
    required num startingCash,
    required String employeeId,
  }) async {
    if (hasOpenShift) {
      throw StateError('A shift is already open');
    }
    if (startingCash < 0) {
      throw ArgumentError('startingCash must be >= 0');
    }
    if (employeeId.isEmpty) {
      throw ArgumentError('employeeId is required');
    }

    final shift = Shift(
      employeeId: employeeId,
      startTime: DateTime.now(),
      startingCash: startingCash,
      status: ShiftStatus.open,
    );

    try {
      await _db.push(shiftsTable, shift.toMap());
      _currentShift = shift;
      Log.ger('shift_opened', {
        'id': shift.id,
        'employeeId': employeeId,
        'startingCash': startingCash,
      });
      notifyListeners();
      return shift;
    } catch (e, stack) {
      Log.err(e, 'shift_open_failed', stack);
      rethrow;
    }
  }

  /// Closes [_currentShift] with counted [actualEndingCash].
  ///
  /// Throws [StateError] if no open shift exists.
  Future<Shift> closeShift(num actualEndingCash) async {
    final open = _currentShift;
    if (open == null || !open.isOpen) {
      throw StateError('No open shift to close');
    }
    if (actualEndingCash < 0) {
      throw ArgumentError('actualEndingCash must be >= 0');
    }

    final closed = open.copyWith(
      endTime: DateTime.now(),
      actualEndingCash: actualEndingCash,
      status: ShiftStatus.closed,
    );

    try {
      await _db.update(shiftsTable, closed.id, closed.toMap());
      _currentShift = null;
      Log.ger('shift_closed', {
        'id': closed.id,
        'actualEndingCash': actualEndingCash,
      });
      notifyListeners();
      return closed;
    } catch (e, stack) {
      Log.err(e, 'shift_close_failed', stack);
      rethrow;
    }
  }

  /// Loads a shift by id (e.g. for Z-report after close).
  Future<Shift?> getShift(String id) async {
    final rows = await _db.query(
      shiftsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Shift.fromMap(rows.first);
  }

  /// Test seam: reset singleton without touching SQLite.
  @visibleForTesting
  void resetSession() {
    _currentShift = null;
    _initialized = false;
  }

  /// Test seam: inject an in-memory open shift.
  @visibleForTesting
  void setCurrentShiftForTest(Shift? shift) {
    _currentShift = shift;
  }
}
