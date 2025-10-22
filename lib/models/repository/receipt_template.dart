import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/receipt_template_object.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/models/repository/receipt_templates.dart';
import 'package:possystem/services/storage.dart';

class ReceiptTemplate extends Model<ReceiptTemplateObject> with ModelStorage<ReceiptTemplateObject> {
  bool isDefault;
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
    this.isDefault = false,
    List<ReceiptComponent>? components,
  }) : components = components ?? _getDefaultComponents();

  factory ReceiptTemplate.fromObject(ReceiptTemplateObject object) => ReceiptTemplate(
        id: object.id,
        name: object.name!,
        isDefault: object.isDefault!,
        components: object.components,
      );

  /// Get default receipt components matching the current hardcoded layout
  static List<ReceiptComponent> _getDefaultComponents() {
    return [
      TextFieldComponent(
        id: 'title',
        text: 'Receipt',
        fontSize: 24.0,
        textAlign: TextAlign.center,
      ),
      OrderTimestampComponent(
        id: 'timestamp',
        dateFormat: 'yMMMd Hms',
      ),
      DividerComponent(id: 'divider1', height: 4.0),
      OrderTableComponent(
        id: 'order_table',
        showProductName: true,
        showCatalogName: false,
        showCount: true,
        showPrice: true,
        showTotal: true,
      ),
      DividerComponent(id: 'divider2', height: 4.0),
      TotalSectionComponent(
        id: 'total_section',
        showDiscounts: true,
        showAddOns: true,
      ),
      DividerComponent(id: 'divider3', height: 4.0),
      PaymentSectionComponent(id: 'payment_section'),
    ];
  }

  @override
  ReceiptTemplateObject toObject() {
    return ReceiptTemplateObject(
      id: id,
      name: name,
      isDefault: isDefault,
      components: components,
    );
  }
}
