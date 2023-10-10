/// Use to help I/O with DB.
abstract class ModelObject<T> {
  /// It is able to be constant most time.
  const ModelObject();

  /// Help diff from other and get the different properties.
  Map<String, Object?> diff(T model);

  /// To map format for DB I/O.
  Map<String, Object?> toMap();
}
