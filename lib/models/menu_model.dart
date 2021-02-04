import 'package:possystem/models/catalog_model.dart';

class MenuModel {
  final Map<String, CatalogModel> _catalogs;

  MenuModel(this._catalogs);

  factory MenuModel.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    try {
      var catalogs = data.map((key, value) {
        if (value is Map) {
          value['name'] = key;
          return MapEntry(key, CatalogModel.fromMap(key, value));
        } else {
          throw TypeError();
        }
      });

      return MenuModel(catalogs);
    } catch (err) {
      return null;
    }
  }

  factory MenuModel.playground() {
    return MenuModel({
      'Hamburger': CatalogModel.add('Hamburger', 0),
      'Drink': CatalogModel.add('Drink', 1),
      'Cookie': CatalogModel.add('Cookie', 2),
    });
  }

  Map<String, dynamic> toMap() {
    return _catalogs.map((key, CatalogModel catalog) {
      return MapEntry(key, catalog.toMap());
    });
  }

  CatalogModel operator [](int index) {
    for (var catalog in _catalogs.values) {
      if (catalog.index == index) return catalog;
    }
    return null;
  }

  int get length => _catalogs.length;
}
