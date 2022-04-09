import 'package:possystem/models/repository.dart';

abstract class Formatter<T> {
  const Formatter();

  List<T> getHead(Repository target);

  List<List<T>> getItems(Repository target);
}
