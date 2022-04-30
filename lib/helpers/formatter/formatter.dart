import 'package:possystem/models/model.dart';
import 'package:possystem/models/repository.dart';

abstract class Formatter<T> {
  const Formatter();

  List<FormattedItem> format(Repository target, List<List<Object?>> rows);

  List<T> getHeader(Repository target);

  List<List<T>> getRows(Repository target);
}

class FormatterValidateError extends Error {
  final String message;

  FormatterValidateError(this.message);
}

class FormattedItem {
  final Model item;

  final FormatterValidateError? error;

  const FormattedItem(this.item, {this.error});

  bool get hasError => error != null;
}
