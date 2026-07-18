/// Occupancy state of a [DiningTable] on the floor plan.
enum TableStatus {
  available,
  occupied;

  /// Persist as TEXT in SQLite (`'available'` / `'occupied'`).
  String get sqlValue => name;

  /// Parse a DB / wire value; unknown values fall back to [available].
  static TableStatus fromSql(Object? raw) {
    if (raw is String) {
      for (final value in TableStatus.values) {
        if (value.name == raw) return value;
      }
    }
    return TableStatus.available;
  }
}
