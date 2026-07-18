import 'package:possystem/helpers/util.dart';
import 'package:possystem/models/tables/table_status.dart';

export 'table_status.dart';

/// A seatable unit belonging to a [Room] on the floor plan.
class DiningTable {
  DiningTable({
    String? id,
    required this.roomId,
    required this.name,
    this.seats = 0,
    this.status = TableStatus.available,
  }) : id = id ?? Util.uuidV4();

  /// Offline-first UUID — never auto-increment (collision-safe across POS).
  final String id;

  /// Parent [Room.id].
  final String roomId;

  /// Label shown on the floor plan (e.g. `"T12"`, `"Terrasse 3"`).
  final String name;

  /// Nominal seat count for the table.
  final int seats;

  final TableStatus status;

  bool get isAvailable => status == TableStatus.available;

  bool get isOccupied => status == TableStatus.occupied;

  DiningTable copyWith({
    String? id,
    String? roomId,
    String? name,
    int? seats,
    TableStatus? status,
  }) {
    return DiningTable(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      seats: seats ?? this.seats,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'name': name,
      'seats': seats,
      'status': status.sqlValue,
    };
  }

  factory DiningTable.fromMap(Map<String, Object?> map) {
    return DiningTable(
      id: map['id'] as String? ?? Util.uuidV4(),
      roomId: map['room_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      seats: (map['seats'] as num?)?.toInt() ?? 0,
      status: TableStatus.fromSql(map['status']),
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DiningTable && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
