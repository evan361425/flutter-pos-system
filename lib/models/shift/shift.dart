import 'package:possystem/helpers/util.dart';

/// Lifecycle of a cash-drawer shift (Z-report session).
enum ShiftStatus {
  open,
  closed;

  String get sqlValue => name;

  static ShiftStatus fromSql(Object? raw) {
    if (raw is String) {
      for (final value in ShiftStatus.values) {
        if (value.name == raw) return value;
      }
    }
    return ShiftStatus.open;
  }
}

/// One physical cash-register shift: float in → sales → counted cash out.
class Shift {
  Shift({
    String? id,
    required this.employeeId,
    required this.startTime,
    this.endTime,
    required this.startingCash,
    this.actualEndingCash,
    this.status = ShiftStatus.open,
  }) : id = id ?? Util.uuidV4();

  final String id;
  final String employeeId;
  final DateTime startTime;
  final DateTime? endTime;
  final num startingCash;
  final num? actualEndingCash;
  final ShiftStatus status;

  bool get isOpen => status == ShiftStatus.open;

  bool get isClosed => status == ShiftStatus.closed;

  Shift copyWith({
    String? id,
    String? employeeId,
    DateTime? startTime,
    DateTime? endTime,
    num? startingCash,
    num? actualEndingCash,
    ShiftStatus? status,
  }) {
    return Shift(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startingCash: startingCash ?? this.startingCash,
      actualEndingCash: actualEndingCash ?? this.actualEndingCash,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'start_time': Util.toUTC(now: startTime),
      'end_time': endTime == null ? null : Util.toUTC(now: endTime),
      'starting_cash': startingCash,
      'actual_ending_cash': actualEndingCash,
      'status': status.sqlValue,
    };
  }

  factory Shift.fromMap(Map<String, Object?> map) {
    final endRaw = map['end_time'];
    return Shift(
      id: map['id'] as String? ?? Util.uuidV4(),
      employeeId: map['employee_id'] as String? ?? '',
      startTime: Util.fromUTC(map['start_time'] as int? ?? 0),
      endTime: endRaw is int ? Util.fromUTC(endRaw) : null,
      startingCash: map['starting_cash'] as num? ?? 0,
      actualEndingCash: map['actual_ending_cash'] as num?,
      status: ShiftStatus.fromSql(map['status']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Shift && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
