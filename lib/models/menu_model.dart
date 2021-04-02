import 'package:flutter/widgets.dart';
import 'package:possystem/models/product_ingredient_model.dart';
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

  CatalogModel buildCatalog({String name}) {
    final catalog = CatalogModel(name: name, index: newIndex);

    addCatalog(catalog);

    return catalog;
  }

  void addCatalog(CatalogModel catalog) {
    Database.service.update(Collections.menu, {
      catalog.id: catalog.toMap(),
    });

    catalogs[catalog.id] = catalog;
    catalogChanged();
  }

  void removeCatalog(String id) {
    catalogs.remove(id);
    Database.service.update(Collections.menu, {id: null});
    catalogChanged();
  }

  int removeIngredient(String id) {
    final products = productContainsIngredient(id);
    final updateData = {
      for (var product in products) '${product.prefix}.$id': null
    };
    Database.service.update(Collections.menu, updateData);

    if (updateData.isNotEmpty) {
      catalogChanged();
      return updateData.length;
    } else {
      return 0;
    }
  }

  List<ProductIngredientModel> productContainsIngredient(String id) {
    final result = <ProductIngredientModel>[];

    catalogs.values.forEach((catalog) {
      catalog.products.values.forEach((product) {
        final ingredient = product.ingredients.remove(id);
        if (ingredient != null) {
          result.add(ingredient);
        }
      });
    });

    return result;
  }

  // HELPER

  void catalogChanged() async {
    notifyListeners();
  }

  bool hasCatalog(String name) {
    return !catalogs.values.every((catalog) => catalog.name != name);
  }

  bool hasProduct(String name) {
    return !catalogs.values.every((catalog) {
      return catalog.products.values.every((product) => product.name != name);
    });
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
