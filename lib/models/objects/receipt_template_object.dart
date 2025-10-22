import 'package:possystem/models/model_object.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/models/repository/receipt_templates.dart';

class ReceiptTemplateObject extends ModelObject<ReceiptTemplate> {
  final String? id;
  final String? name;
  final bool? isDefault;
  final List<ReceiptComponent>? components;

  ReceiptTemplateObject({
    this.id,
    this.name,
    this.isDefault,
    this.components,
  });

  @override
  Map<String, Object> toMap() {
    return {
      'name': name!,
      'isDefault': isDefault!,
      'components': components!.map((c) => c.toJson()).toList(),
    };
  }

  @override
  Map<String, Object> diff(ReceiptTemplate model) {
    final result = <String, Object>{};
    final prefix = model.prefix;

    if (name != null && name != model.name) {
      model.name = name!;
      result['$prefix.name'] = name!;
    }
    if (isDefault != null && isDefault != model.isDefault) {
      model.isDefault = isDefault!;
      result['$prefix.isDefault'] = isDefault!;
    }
    if (components != null) {
      model.components = components!;
      result['$prefix.components'] = components!.map((c) => c.toJson()).toList();
    }

    return result;
  }

  factory ReceiptTemplateObject.build(Map<String, Object?> data) {
    final componentsList = data['components'] as List?;
    return ReceiptTemplateObject(
      id: data['id'] as String,
      name: data['name'] as String,
      isDefault: data['isDefault'] as bool,
      components: componentsList?.map((e) => ReceiptComponent.fromJson(e as Map<String, Object?>)).toList(),
    );
  }
}
