import 'package:possystem/models/catalog_model.dart';

class MenuModel {
  final List<CatalogModel> catalogs;

  MenuModel(this.catalogs);

  factory MenuModel.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    return MenuModel(data['catalogs']);
  }

  factory MenuModel.playground() {
    return MenuModel([
      CatalogModel.add('Hamburger'),
      CatalogModel.add('Coffee'),
      CatalogModel.add('Cookie'),
    ]);
  }

  Map<String, dynamic> toMap() {
    return {
      'catalogs': catalogs.map((catalog) => catalog.toMap()).toList(),
    };
  }
}
