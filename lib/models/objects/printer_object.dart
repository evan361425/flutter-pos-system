import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/printer/printer.dart';

class PrinterObject extends ModelObject<Printer> {
  PrinterObject({
    this.id,
    this.name,
    this.address,
    this.usage,
  });

  final String? id;
  final String? name;
  final String? address;
  final PrinterUsage? usage;

  @override
  Map<String, Object> toMap() {
    return {
      'name': name!,
      'address': address!,
      'usage': usage!.index,
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
    if (usage != null && usage != model.usage) {
      model.usage = usage!;
      result['$prefix.usage'] = usage!.index;
    }

    return result;
  }

  factory PrinterObject.build(Map<String, Object?> data) {
    return PrinterObject(
      id: data['id'] as String,
      name: data['name'] as String,
      address: data['address'] as String,
      usage: PrinterUsage.values.elementAtOrNull(data['usage'] as int) ?? PrinterUsage.unassigned,
    );
  }
}
