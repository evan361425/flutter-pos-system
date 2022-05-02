import 'package:possystem/models/model.dart';
import 'package:possystem/models/repository.dart';

abstract class Formatter<T> {
  const Formatter();

  List<FormattedItem<U>> format<U extends Model>(
    Repository target,
    List<List<Object?>> rows,
  );

  List<T> getHeader(Repository target);

  List<List<T>> getRows(Repository target);
}

class FormatterValidateError extends Error {
  final String message;

  final String raw;

  FormatterValidateError(this.message, this.raw);
}

class FormattedItem<T extends Model> {
  final T? item;

  final FormatterValidateError? error;

  const FormattedItem({this.item, this.error});

  bool get hasError => error != null;
}
