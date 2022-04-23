import 'package:possystem/models/model.dart';
import 'package:possystem/models/repository.dart';

abstract class Formatter<T> {
  const Formatter();

  List<FormattedItem> format(Repository target, List<List<Object?>> rows);

  List<T> getHead(Repository target);

  List<List<T>> getItems(Repository target);
}

class FormatterValidateError extends Error {
  final String message;

  final int index;

  FormatterValidateError(this.message, this.index);
}

class FormattedItem {
  final Model? item;

  final FormatterValidateError? error;

  const FormattedItem({
    this.item,
    this.error,
  });

  bool get hasError => error != null;
}
