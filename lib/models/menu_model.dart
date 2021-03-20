import 'package:flutter/widgets.dart';
import 'package:possystem/services/database.dart';

import 'catalog_model.dart';

class MenuModel extends ChangeNotifier {
  MenuModel() {
    loadFromDb();
  }

  Map<String, CatalogModel> catalogs;

  // I/O

  Future<void> loadFromDb() async {
    var snapshot = await Database.service.get(Collections.menu);
    buildFromMap(snapshot.data());

    notifyListeners();
  }

  void buildFromMap(Map<String, dynamic> data) {
    catalogs = {};
    if (data == null) return;

    try {
      data.forEach((key, value) {
        if (value is Map) {
          catalogs[key] = CatalogModel.fromMap({'id': key, ...value});
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Map<String, Map<String, dynamic>> toMap() {
    return {for (var entry in catalogs.entries) entry.key: entry.value.toMap()};
  }

  // STATE CHANGER

  Future<CatalogModel> buildCatalog({String name}) async {
    final catalog = CatalogModel(name: name, index: newIndex);

    await addCatalog(catalog);

    return catalog;
  }

  Future<void> addCatalog(CatalogModel catalog) async {
    await Database.service.update(Collections.menu, {
      catalog.id: catalog.toMap(),
    });

    catalogs[catalog.id] = catalog;
    notifyListeners();
  }

  // SETTER

  Future<void> catalogChanged() async {
    notifyListeners();
  }

  // HELPER

  bool has(String name) {
    return !catalogs.values.every((catalog) => catalog.name != name);
  }

  // GETTER

  CatalogModel operator [](String id) {
    return catalogs[id];
  }

  List<CatalogModel> get catalogList {
    final catalogList = catalogs.values.toList();
    catalogList.sort((a, b) => a.index.compareTo(b.index));
    return catalogList;
  }

  int get newIndex {
    var maxIndex = -1;
    catalogs.forEach((key, catalog) {
      if (catalog.index > maxIndex) {
        maxIndex = catalog.index;
      }
    });
    return maxIndex + 1;
  }

  bool get isNotReady => catalogs == null;

  int get length => catalogs.length;
}
