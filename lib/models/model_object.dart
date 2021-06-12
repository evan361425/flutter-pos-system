abstract class ModelObject<T> {
  Map<String, Object> diff(T model);
  Map<String, Object?> toMap();
}
