import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/printer_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/printers.dart';
import 'package:possystem/services/storage.dart';

class Printer extends Model<PrinterObject> with ModelStorage<PrinterObject> {
  String address;

  PrinterUsage usage;

  @override
  final Stores storageStore = Stores.printers;

  Printer({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'printer',
    this.address = '',
    this.usage = PrinterUsage.unassigned,
  });

  factory Printer.fromObject(PrinterObject object) => Printer(
        id: object.id,
        name: object.name!,
        address: object.address!,
        usage: PrinterUsage.unassigned,
      );

  @override
  PrinterObject toObject() {
    return PrinterObject(
      id: id,
      name: name,
      address: address,
      usage: usage,
    );
  }

  @override
  Printers get repository => Printers.instance;

  @override
  set repository(Repository repo) {}
}

enum PrinterUsage {
  unassigned,
  receipt,
}
