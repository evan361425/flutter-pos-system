/// Base class for order-related objects that persist in two formats.
abstract class OrderSerializable {
  const OrderSerializable();

  /// Map format for history / SQLite I/O.
  Map<String, Object?> toMap();

  /// Map format for stash and restore.
  Map<String, Object?> toStashMap();
}
