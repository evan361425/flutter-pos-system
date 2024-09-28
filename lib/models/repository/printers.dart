import 'package:flutter/foundation.dart';
import 'package:possystem/models/objects/printer_object.dart';
import 'package:possystem/models/printer/printer.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';

class Printers extends ChangeNotifier with Repository<Printer>, RepositoryStorage<Printer> {
  static late Printers instance;

  @override
  final Stores storageStore = Stores.printers;

  Printers() {
    instance = this;
  }

  @override
  Printer buildItem(String id, Map<String, Object?> value) {
    return Printer.fromObject(
      PrinterObject.build({
        'id': id,
        ...value,
      }),
    );
  }
}
