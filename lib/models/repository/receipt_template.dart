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
        text: '{title}',
        fontSize: 28.0,
        textAlign: TextAlign.center,
      ),
      TextFieldComponent(text: '{createdAt}', textAlign: TextAlign.center),
      OrderTableComponent(
        showProductName: true,
        showCount: true,
        showPrice: true,
        showTotal: true,
      ),
      DiscountTableComponent(
        showProductName: true,
        showOriginalPrice: true,
      ),
      AttributeTableComponent(
        showOptionName: true,
        showAdjustment: true,
      ),
      PriceTableComponent(
        showPaid: true,
        showPrice: true,
        showChange: true,
      )
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
}
