import 'package:flutter/widgets.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/receipt_template_object.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/services/storage.dart';

class ReceiptTemplate extends Model<ReceiptTemplateObject> with ModelStorage<ReceiptTemplateObject> {
  List<ReceiptComponent> components;

  @override
  final Stores storageStore = Stores.receiptTemplates;

  @override
  ReceiptTemplates get repository => ReceiptTemplates.instance;

  @override
  String get prefix => 'template.$id';

  bool get isSelected => ReceiptTemplates.instance.selected.id == id;
  bool get isDefault => id == 'default';

  ReceiptTemplate({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'receipt template',
    List<ReceiptComponent>? components,
  }) : components = components ?? const [];

  factory ReceiptTemplate.fromObject(ReceiptTemplateObject object) => ReceiptTemplate(
        id: object.id,
        name: object.name!,
        components: object.components,
      );

  /// Get default receipt components matching the current hardcoded layout
  static List<ReceiptComponent> getDefaultComponents() {
    return [
      TextFieldComponent(
        texts: [
          StyledPlaceholderObject.fromType(TextFieldPlaceholderType.title, fontSize: 28),
          StyledTextObject.fromText('\n'),
          StyledPlaceholderObject.fromType(TextFieldPlaceholderType.orderedAt, meta: ''),
        ],
        textAlign: TextAlign.center,
        padding: const EdgeInsets.only(bottom: 4),
      ),
      OrderTableComponent(padding: const EdgeInsets.only(bottom: 4)),
      DiscountTableComponent(padding: const EdgeInsets.only(bottom: 4)),
      AttributeTableComponent(padding: const EdgeInsets.only(bottom: 4)),
      PriceTableComponent(padding: const EdgeInsets.only(bottom: 4))
    ];
  }

  @override
  ReceiptTemplateObject toObject() {
    return ReceiptTemplateObject(
      id: id,
      name: name,
      components: components,
    );
  }

  @override
  Future<void> update(ReceiptTemplateObject object, {String event = 'update'}) async {
    // although default template is not editable in UI, but prevent updating by routing
    if (!isDefault) {
      await super.update(object, event: event);
    }
  }
}
