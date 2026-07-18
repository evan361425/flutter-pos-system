import 'package:possystem/helpers/util.dart';

/// Physical dining area (salle) shown as a tab on the floor plan.
class Room {
  Room({String? id, required this.name, this.sequence = 0})
    : id = id ?? Util.uuidV4();

  /// Offline-first UUID — never auto-increment (collision-safe across POS).
  final String id;

  final String name;

  /// Display order for room tabs (ascending).
  final int sequence;

  Room copyWith({String? id, String? name, int? sequence}) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
    );
  }

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'sequence': sequence};
  }

  factory Room.fromMap(Map<String, Object?> map) {
    return Room(
      id: map['id'] as String? ?? Util.uuidV4(),
      name: map['name'] as String? ?? '',
      sequence: (map['sequence'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Room && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
