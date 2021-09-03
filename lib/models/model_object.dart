abstract class ModelObject<T> {
  const ModelObject();

  Map<String, Object?> diff(T model);
  Map<String, Object?> toMap();
}
