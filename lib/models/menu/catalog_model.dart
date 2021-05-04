import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:possystem/helper/util.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/services/database.dart';
import 'package:sprintf/sprintf.dart';

import 'product_model.dart';

class CatalogModel extends ChangeNotifier {
  CatalogModel({
    DateTime createdAt,
    String id,
    @required int index,
    @required this.name,
    Map<String, ProductModel> products,
  })  : createdAt = createdAt ?? DateTime.now(),
        products = products ?? {},
        id = id ?? Util.uuidV4();

  final String id;
  // catalog's name
  String name;
  // index in menu
  int index;
  // when it has been added to menu
  final DateTime createdAt;
  // product list
  final Map<String, ProductModel> products;

  factory CatalogModel.fromMap(Map<String, dynamic> data) {
    final object = CatalogObject.build(data);

    final catalog = CatalogModel(
      id: object.id,
      index: object.index,
      name: object.name,
      createdAt: object.createdAt,
      products: {
        for (var product in object.products)
          product.id: ProductModel.fromMap(product)
      },
    );

    catalog.products.values.forEach((e) {
      e.catalog = catalog;
    });

    return catalog;
  }

  CatalogObject toObject() {
    return CatalogObject(
      id: id,
      index: index,
      name: name,
      createdAt: createdAt,
      products: products.values.map((e) => e.toObject()),
    );
  }

  Future<void> update(CatalogObject catalog) {
    final updateData = catalog.diff(this);

    if (updateData.isEmpty) return Future.value();

    notifyListeners();

    return Database.instance.update(Collections.menu, updateData);
  }

  Future<void> reorderProducts(List<ProductModel> products) {
    final updateData = <String, dynamic>{};
    var i = 1;

    products.forEach((product) {
      updateData.addAll(ProductObject.build({'index': i++}).diff(product));
    });

    notifyListeners();

    return Database.instance.update(Collections.menu, updateData);
  }

  void updateProduct(ProductModel product) {
    if (!products.containsKey(product.id)) {
      products[product.id] = product;

      final updateData = {product.prefix: product.toObject().toMap()};
      Database.instance.update(Collections.menu, updateData);
    }

    notifyListeners();
  }

  void removeProduct(ProductModel product) {
    products.remove(product.id);

    Database.instance.update(Collections.menu, {product.prefix: null});

    notifyListeners();
  }

  // void productChanged() {
  //   notifyListeners();
  // }

  ProductModel operator [](String id) => products[id];

  List<ProductModel> get productList {
    final productList = products.values.toList();
    productList.sort((a, b) => a.index.compareTo(b.index));
    return productList;
  }

  int get newIndex {
    var maxIndex = 0;
    products.forEach((id, product) {
      if (product.index > maxIndex) {
        maxIndex = product.index;
      }
    });
    return maxIndex + 1;
  }

  String get createdDate {
    return sprintf('%04d-%02d-%02d', [
      createdAt.year,
      createdAt.month,
      createdAt.day,
    ]);
  }

  bool get isEmpty => products.isEmpty;
  bool get isNotEmpty => products.isNotEmpty;
  int get length => products.length;
}
