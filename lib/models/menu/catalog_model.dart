import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu_model.dart';
import 'package:possystem/services/storage.dart';
import 'package:sprintf/sprintf.dart';

import 'product_model.dart';

class CatalogModel extends ChangeNotifier {
  final String id;

  /// catalog's name
  String name;

  /// index in menu
  int index;

  /// when it has been added to menu
  final DateTime createdAt;

  /// product list
  final Map<String, ProductModel> products;

  CatalogModel({
    DateTime createdAt,
    String id,
    @required this.index,
    @required this.name,
    Map<String, ProductModel> products,
  })  : createdAt = createdAt ?? DateTime.now(),
        products = products ?? {},
        id = id ?? Util.uuidV4();

  factory CatalogModel.fromObject(CatalogObject object) => CatalogModel(
        id: object.id,
        index: object.index,
        name: object.name,
        createdAt: object.createdAt,
        products: {
          for (var product in object.products)
            product.id: ProductModel.fromMap(product)
        },
      ).._preparePorducts();

  String get createdDate => sprintf('%04d-%02d-%02d', [
        createdAt.year,
        createdAt.month,
        createdAt.day,
      ]);

  bool get isEmpty => products.isEmpty;
  bool get isNotEmpty => products.isNotEmpty;
  int get length => products.length;

  /// 1-index
  int get newIndex => products.length + 1;

  /// sorted by index
  List<ProductModel> get productList =>
      products.values.toList()..sort((a, b) => a.index.compareTo(b.index));

  bool exist(String id) => products.containsKey(id);

  ProductModel getProduct(String id) => exist(id) ? products[id] : null;

  Future<void> remove() async {
    print('remove catalog $name');
    await Storage.instance.set(Stores.menu, {id: null});

    MenuModel.instance.removeCatalog(id);
  }

  void removeProduct(String id) {
    products.remove(id);

    notifyListeners();
  }

  Future<void> reorderProducts(List<ProductModel> products) {
    final updateData = <String, int>{};
    var i = 1;

    products.forEach((product) {
      updateData.addAll(ProductObject.build({'index': i++}).diff(product));
    });

    notifyListeners();

    return Storage.instance.set(Stores.menu, updateData);
  }

  CatalogObject toObject() => CatalogObject(
        id: id,
        index: index,
        name: name,
        createdAt: createdAt,
        products: products.values.map((e) => e.toObject()),
      );

  Future<void> update(CatalogObject catalog) {
    final updateData = catalog.diff(this);

    if (updateData.isEmpty) return Future.value();

    notifyListeners();

    return Storage.instance.set(Stores.menu, updateData);
  }

  void updateProduct(ProductModel product) {
    if (!exist(product.id)) {
      products[product.id] = product;

      final updateData = {product.prefix: product.toObject().toMap()};

      Storage.instance.set(Stores.menu, updateData);
    }

    notifyListeners();
  }

  void _preparePorducts() {
    products.values.forEach((e) {
      e.catalog = this;
    });
  }
}
