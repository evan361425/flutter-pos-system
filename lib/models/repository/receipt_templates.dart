import 'package:flutter/material.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/receipt_template_object.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/receipt_template.dart';
import 'package:possystem/services/storage.dart';

class ReceiptTemplates extends ChangeNotifier with Repository<ReceiptTemplate>, RepositoryStorage<ReceiptTemplate> {
  static late ReceiptTemplates instance;

  @override
  final Stores storageStore = Stores.receiptTemplates;

  ReceiptTemplates() {
    instance = this;
  }

  @override
  List<ReceiptTemplate> get itemList => items.toList();

  @override
  RepositoryStorageType get repoType => RepositoryStorageType.repoProperties;

  ReceiptTemplate? get defaultTemplate {
    try {
      return items.firstWhere((template) => template.isDefault);
    } catch (e) {
      return null;
    }
  }

  /// Get the current enabled template's components, or default if none enabled
  List<ReceiptComponent> get currentComponents {
    final template = defaultTemplate;
    if (template != null) {
      return template.components;
    }
    // Return default components if no template is enabled
    return ReceiptTemplate._getDefaultComponents();
  }

  Future<void> clearDefault() async {
    final template = defaultTemplate;

    if (template != null) {
      await template.update(ReceiptTemplateObject(
        isDefault: false,
        // Keep other values
        name: template.name,
        components: template.components,
      ));
    }
  }

  @override
  ReceiptTemplate buildItem(String id, Map<String, Object?> value) {
    return ReceiptTemplate.fromObject(
      ReceiptTemplateObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  @override
  Future<void> initialize({String? record}) async {
    await super.initialize(record: 'template');

    // Create default template if empty
    if (isEmpty) {
      await addItem(ReceiptTemplate(
        name: 'Default Template',
        isDefault: true,
        components: ReceiptTemplate._getDefaultComponents(),
      ));
    }
  }
}
