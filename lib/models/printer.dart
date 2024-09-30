import 'package:flutter/foundation.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/model_object.dart';
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

class Printer extends Model<PrinterObject> with ModelStorage<PrinterObject> {
  String address;

  bool defaultReceiptPrinter = false;

  bool connected;

  @override
  final Stores storageStore = Stores.printers;

  Printer({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'printer',
    this.address = '',
    this.connected = false,
    this.defaultReceiptPrinter = false,
  });

  factory Printer.fromObject(PrinterObject object) => Printer(
        id: object.id,
        name: object.name!,
        address: object.address!,
        defaultReceiptPrinter: object.defaultReceiptPrinter!,
      );

  @override
  PrinterObject toObject() {
    return PrinterObject(
      id: id,
      name: name,
      address: address,
      defaultReceiptPrinter: defaultReceiptPrinter,
    );
  }

  @override
  Printers get repository => Printers.instance;

  @override
  set repository(Repository repo) {}

  int compareTo(Printer other) {
    if (defaultReceiptPrinter) {
      return -1;
    }

    if (other.defaultReceiptPrinter) {
      return 1;
    }

    return 0;
  }
}

class PrinterObject extends ModelObject<Printer> {
  PrinterObject({
    this.id,
    this.name,
    this.address,
    this.defaultReceiptPrinter,
  });

  final String? id;
  final String? name;
  final String? address;
  final bool? defaultReceiptPrinter;

  @override
  Map<String, Object> toMap() {
    return {
      'name': name!,
      'address': address!,
      'defaultReceiptPrinter': defaultReceiptPrinter!,
    };
  }

  @override
  Map<String, Object> diff(Printer model) {
    final result = <String, Object>{};
    final prefix = model.prefix;

    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (address != null && address != model.address) {
      model.address = address!;
      result['$prefix.address'] = address!;
    }
    if (defaultReceiptPrinter != null && defaultReceiptPrinter != model.defaultReceiptPrinter) {
      model.defaultReceiptPrinter = defaultReceiptPrinter!;
      result['$prefix.defaultReceiptPrinter'] = defaultReceiptPrinter!;
    }

    return result;
  }

  factory PrinterObject.build(Map<String, Object?> data) {
    return PrinterObject(
      id: data['id'] as String,
      name: data['name'] as String,
      address: data['address'] as String,
      defaultReceiptPrinter: data['defaultReceiptPrinter'] as bool,
    );
  }
}
