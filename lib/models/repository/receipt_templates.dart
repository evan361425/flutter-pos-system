import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/objects/receipt_template_object.dart';
import 'package:possystem/models/repository.dart';
import 'package:possystem/models/repository/receipt_template.dart';
import 'package:possystem/services/storage.dart';

const _defaultId = 'default';

class ReceiptTemplates extends ChangeNotifier with Repository<ReceiptTemplate>, RepositoryStorage<ReceiptTemplate> {
  static late ReceiptTemplates instance;

  @override
  final Stores storageStore = Stores.receiptTemplates;

  String? selectedId;

  ReceiptTemplates() {
    instance = this;
  }

  @override
  Future<void> initialize({String? record}) async {
    await super.initialize(record: record);

    final data = await Storage.instance.get(storageStore, 'setting');
    selectedId = data['selectedId'] as String?;

    await addItem(
      ReceiptTemplate(
        id: _defaultId,
        name: '',
        components: ReceiptTemplate.getDefaultComponents(),
      ),
      save: false,
    );
  }

  @override
  RepositoryStorageType get repoType => RepositoryStorageType.repoModel;

  /// Get the current enabled template
  ReceiptTemplate get selected => getItem(selectedId ?? _defaultId)!;

  @override
  ReceiptTemplate buildItem(String id, Map<String, Object?> value) {
    return ReceiptTemplate.fromObject(
      ReceiptTemplateObject.build({
        'id': id,
        ...value,
      }),
    );
  }

  Future<void> changeSelected(String id) async {
    selectedId = id;
    await _saveProperties();
  }

  Future<void> _saveProperties() async {
    Log.ger('update_repo', {'type': storageStore.name});

    await Storage.instance.set(storageStore, {
      'setting': {
        'selectedId': selectedId,
      },
    });

    notifyListeners();
  }
}
