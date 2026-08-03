import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/model.dart';
import 'package:possystem/models/objects/receipt_template_object.dart';
import 'package:possystem/models/receipt_component.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/services/storage.dart';
import 'package:possystem/translator.dart';

const _defaultId = '__default';

class ReceiptTemplates extends ChangeNotifier with Repository<ReceiptTemplate>, RepositoryStorage<ReceiptTemplate> {
  static late ReceiptTemplates instance;

  @override
  final Stores storageStore = .receiptTemplates;

  @override
  RepositoryStorageType get repoType => .repoModel;

  String? selectedId;

  ReceiptTemplates() {
    instance = this;
  }

  @visibleForTesting
  static void reset() {
    ReceiptTemplates().prepareDefault();
  }

  @override
  Future<void> initialize({String? record}) async {
    await super.initialize(record: record);

    final data = await Storage.instance.get(storageStore, 'setting');
    selectedId = data['selectedId'] as String?;

    prepareDefault();
  }

  /// Get the current enabled template
  ReceiptTemplate get selected => getItem(selectedId ?? _defaultId)!;

  @override
  ReceiptTemplate buildItem(String id, Map<String, Object?> value) {
    return ReceiptTemplate.fromObject(ReceiptTemplateObject.build({'id': id, ...value}));
  }

  Future<void> changeSelected(String id) async {
    if (selectedId != id) {
      selectedId = id;
      await _saveProperties();
    }
  }

  @visibleForTesting
  void prepareDefault() async {
    await addItem(
      ReceiptTemplate(id: _defaultId, name: '', components: ReceiptTemplate.getDefaultComponents()),
      save: false,
    );
  }

  Future<void> _saveProperties() async {
    Log.ger('update_repo', {'type': storageStore.name});

    await Storage.instance.set(storageStore, {
      'setting': {'selectedId': selectedId},
    });

    notifyListeners();
  }
}

class ReceiptTemplate extends Model<ReceiptTemplateObject> with ModelStorage<ReceiptTemplateObject> {
  List<ReceiptComponent> components;

  @override
  final Stores storageStore = .receiptTemplates;

  @override
  ReceiptTemplates get repository => .instance;

  @override
  String get prefix => 'template.$id';

  bool get isSelected => ReceiptTemplates.instance.selected.id == id;
  bool get isDefault => id == '__default';

  ReceiptTemplate({
    super.id,
    super.status = ModelStatus.normal,
    super.name = 'receipt template',
    List<ReceiptComponent>? components,
  }) : components = components ?? const [];

  factory ReceiptTemplate.fromObject(ReceiptTemplateObject object) =>
      ReceiptTemplate(id: object.id, name: object.name!, components: object.components);

  /// Get default receipt components matching the current hardcoded layout
  static List<ReceiptComponent> getDefaultComponents() {
    return [
      TextFieldComponent(
        texts: [StyledPlaceholderObject.fromType(.title, fontSize: 28, height: 1, letterSpacing: 0)],
        textAlign: .center,
        padding: const .only(bottom: 4),
      ),
      TextFieldComponent(
        texts: [StyledPlaceholderObject.fromType(.orderedAt, meta: 'yMMMd Hms')],
        textAlign: .center,
        padding: const .only(bottom: 4),
      ),
      OrderTableComponent(),
      DiscountTableComponent(padding: const .only(top: 4)),
      AttributeTableComponent(padding: const .only(top: 4)),
      PriceTableComponent(),
    ];
  }

  String get displayName => name == '' ? S.printerReceiptTemplateDefaultName : name;

  @override
  ReceiptTemplateObject toObject() {
    return ReceiptTemplateObject(id: id, name: name, components: components);
  }

  @override
  Future<void> update(ReceiptTemplateObject object, {String event = 'update'}) async {
    // although default template is not editable in UI, but prevent updating by routing
    if (!isDefault) {
      await super.update(object, event: event);
    }
  }
}
